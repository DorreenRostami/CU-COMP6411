-module(game).
-export([start/1]).

start(Args) ->
    rand:seed(exsss),
    PlayerFile = lists:nth(1, Args),
    {ok, PlayerInfo} = file:consult(PlayerFile),
    register(master, self()),
    % io:fwrite("it is ~w\n", [[Name || {Name, _} <- PlayerInfo]]),
    [spawn(player, run, [Player_Name, [Name || {Name, _} <- PlayerInfo]]) || {Player_Name, _} <- PlayerInfo],
    main_loop(PlayerInfo, [], PlayerInfo, []).
    

main_loop(InitialPI, GameList, PlayerInfo, DisqualifiedPlayers) ->
    receive
        {new_game, Player1, Player2} ->
            NewGameID = length(GameList) + 1,
            Player1_PID = whereis(Player1),
            Player2_PID = whereis(Player2),
            Player1_PID ! {make_a_move, NewGameID},
            Player2_PID ! {make_a_move, NewGameID},
            io:fwrite("+[~w] new game for ~w -> ~w~n", [NewGameID, Player1, Player2]),
            main_loop(InitialPI, [{NewGameID, {Player1, Player2}, []} | GameList], PlayerInfo, DisqualifiedPlayers);
        {moved, GameID, Name, Move} ->
            {NewGameList, NewPlayerInfo, NewDisqualifiedPlayers} = handle_move(GameList, PlayerInfo, DisqualifiedPlayers, GameID, Name, Move),
            if
                length(NewDisqualifiedPlayers) + 1 == length(NewPlayerInfo) -> %one player (winner) left
                    lists:foreach( %stop all the players
                        fun({PName, _}) ->
                            Pid = whereis(PName),
                            Pid ! {end_game}
                        end,
                        NewPlayerInfo
                    ),
                    io:fwrite("~nWe have a winner...~n~n** Tournament Report **~n~nPlayers:~n"),
                    ZippedList = lists:zip(NewPlayerInfo, InitialPI),
                    lists:foreach(
                        fun({{Name_, RemCredit}, {Name_, InitialCredit}}) ->
                            io:format(" ~s: credits used: ~w, credits remaining: ~w~n", [Name_, InitialCredit-RemCredit, RemCredit])
                        end,
                        ZippedList
                    ),
                    io:format(" -----~n Total games: ~w~n~n", [length(GameList)]),
                    {WinnerName, _} = lists:nth(1, find_last_player(NewPlayerInfo, NewDisqualifiedPlayers)),
                    io:fwrite("winner: ~w~n", [WinnerName]),
                    io:fwrite("~nSee you next year...~n");
                true -> main_loop(InitialPI, NewGameList, NewPlayerInfo, NewDisqualifiedPlayers)
            end
    end.

handle_move(GameList, PlayerInfo, DisqualifiedPlayers, GameID, Name, Move) ->
    {GameID, {Player1, Player2}, OldMoves} = lists:keyfind(GameID, 1, GameList),
    NewGameList = update_game_moves(GameID, Name, Move, OldMoves, GameList),
    {_, _, Moves} = lists:keyfind(GameID, 1, NewGameList),
    if 
        length(Moves) rem 2 == 1 -> %other player hasn't made a move yet
            {NewGameList, PlayerInfo, DisqualifiedPlayers};
        true ->
            {P1, M1} = lists:nth(2, Moves),
            {P2, M2} = lists:nth(1, Moves),
            Result = determine_winner(P1, M1, P2, M2),
            P1_PID = whereis(P1),
            P2_PID = whereis(P2),
            case Result of
                tie ->
                    P1_PID ! {make_a_move, GameID},
                    P2_PID ! {make_a_move, GameID},
                    {NewGameList, PlayerInfo, DisqualifiedPlayers};
                {winner, P2} ->
                    {_, OldCredits} = lists:keyfind(P1, 1, PlayerInfo),
                    if
                        OldCredits == 0 ->
                            print_game_outcome("$", GameID, Player1, Player2, Moves, P1, OldCredits),
                            {NewGameList, PlayerInfo, DisqualifiedPlayers};
                        true ->
                            UpdatedPlayerInfo = dec_player_credits(P1, PlayerInfo),
                            {P1, Credits} = lists:keyfind(P1, 1, UpdatedPlayerInfo),
                            if 
                                Credits == 0 ->
                                    NewDisqualifiedPlayers = [P1 | DisqualifiedPlayers],
                                    P1_PID ! {disqualified},
                                    print_game_outcome("-", GameID, Player1, Player2, Moves, P1, Credits),
                                    {NewGameList, UpdatedPlayerInfo, NewDisqualifiedPlayers};
                                true ->
                                    print_game_outcome("$", GameID, Player1, Player2, Moves, P1, Credits),
                                    {NewGameList, UpdatedPlayerInfo, DisqualifiedPlayers}
                            end
                    end;
                {winner, P1} ->
                    {_, OldCredits} = lists:keyfind(P2, 1, PlayerInfo),
                    if
                        OldCredits == 0 ->
                            print_game_outcome("$", GameID, Player1, Player2, Moves, P2, OldCredits),
                            {NewGameList, PlayerInfo, DisqualifiedPlayers};
                        true ->
                            UpdatedPlayerInfo = dec_player_credits(P2, PlayerInfo),
                            {P2, Credits} = lists:keyfind(P2, 1, UpdatedPlayerInfo),
                            if 
                                Credits == 0 ->
                                    NewDisqualifiedPlayers = [P2 | DisqualifiedPlayers],
                                    P2_PID ! {disqualified},
                                    print_game_outcome("-", GameID, Player1, Player2, Moves, P2, Credits),
                                    {NewGameList, UpdatedPlayerInfo, NewDisqualifiedPlayers};
                                true ->
                                    print_game_outcome("$", GameID, Player1, Player2, Moves, P2, Credits),
                                    {NewGameList, UpdatedPlayerInfo, DisqualifiedPlayers}
                            end
                    end
            end
    end.


update_game_moves(GameID, Name, Move, Moves, GameList) ->
    NewMoves = [{Name, Move} | Moves],
    lists:map(
        fun({ID, Players, _}) when ID =:= GameID -> {ID, Players, NewMoves};
           (Other) -> Other
        end,
        GameList
    ).

dec_player_credits(P1, PlayerInfo) ->
    lists:map(
        fun({Name, Credits}) when Name =:= P1 -> 
            if Credits > 0 ->
                {Name, Credits-1};
            true ->
                {Name, Credits}
            end;
           (Other) -> Other
        end,
        PlayerInfo
    ).

determine_winner(P1, M1, P2, M2) ->
    case {M1, M2} of
        {rock, scissors} -> {winner, P1};
        {paper, rock} -> {winner, P1};
        {scissors, paper} -> {winner, P1};
        {scissors, rock} -> {winner, P2};
        {rock, paper} -> {winner, P2};
        {paper, scissors} -> {winner, P2};
        _ -> tie
    end.

print_game_outcome(Symbol, GameID, Player1, Player2, Moves, Loser, LoserCredits) ->
    io:fwrite("~s(~w) ", [Symbol, GameID]),
    print_pairs_from_end(Player1, Player2, Moves),
    io:fwrite(" = ~w loses [~w credits left]\n", [Loser, LoserCredits]).

print_pairs_from_end(_, _, []) -> ok;
print_pairs_from_end(Player1, Player2, [{P1, M1}, {P2, M2} | Rest]) ->
    print_pairs_from_end(Player1, Player2, Rest),
    if
        length(Rest) == 0 ->
            if
                P1 == Player1 ->
                    io:format("~s:~s -> ~s:~s", [P1, M1, P2, M2]);
                true ->
                    io:format("~s:~s -> ~s:~s", [P2, M2, P1, M1])
            end;
        true ->
            if
                P1 == Player1 ->
                    io:format(", ~s:~s -> ~s:~s", [P1, M1, P2, M2]);
                true ->
                    io:format(", ~s:~s -> ~s:~s", [P2, M2, P1, M1])
            end
    end.


find_last_player(PlayerInfo, DisqualifiedPlayers) ->
    lists:filter(
        fun({Name, _Credit}) -> 
            not lists:member(Name, DisqualifiedPlayers) 
        end,
        PlayerInfo
    ).