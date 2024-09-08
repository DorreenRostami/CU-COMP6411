-module(player).
-export([run/2]).

run(Name, PlayerNames) ->
    register(Name, self()),
    timer:sleep(200),
    Names = lists:delete(Name, PlayerNames),  
    loop(Name, Names, 0).

loop(Name, PlayerNames, Disqualified) ->
    receive
        {wanna_play, FromID} ->
            if 
                Disqualified == 1 ->
                    FromID ! {disqualified_opponent, Name};
                true ->
                    FromID ! {lets_play, Name}
            end,
            loop(Name, PlayerNames, Disqualified);
        {lets_play, OpponentName} ->
            master ! {new_game, Name, OpponentName},
            loop(Name, PlayerNames, Disqualified);
        {disqualified_opponent, Opponent} ->
            NewNames = lists:delete(Opponent, PlayerNames),
            loop(Name, NewNames, Disqualified);
        {make_a_move, GameID} ->
            Move = lists:nth(rand:uniform(3), [rock, paper, scissors]), %rand 1 or 2 or 3
            master ! {moved, GameID, Name, Move},
            loop(Name, PlayerNames, Disqualified);
        {disqualified} ->
            loop(Name, PlayerNames, 1);
        {end_game} ->
            ok
    after 100 ->
        if 
            length(PlayerNames) > 0 andalso Disqualified == 0 ->
                RandName = lists:nth(rand:uniform(length(PlayerNames)), PlayerNames), %rand produces a number in [1, len(PlayerNames)]
                RandID = whereis(RandName),
                RandID ! {wanna_play, self()};
            true -> ok
        end,
        loop(Name, PlayerNames, Disqualified)
    end.
   
