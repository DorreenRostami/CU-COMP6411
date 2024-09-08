This is a solo project

p.s:
I asked a TA about disqualified players playing an ongoing game and how we should handle the scenarios and he said it just depends on my implementation so I thought I should point these out:
1) When an already disqualified player loses another game, the message won't be shown with "-" at the start, it will be shown with "$".
2) As soon as there is only one player with credits left, the tournament ends and all the other ongoing games will be stopped. This is to prevent the scenario where all players have 0 credits left (the winner lost in another ongoing game). This might happen when there are 2 players (both with 1 credit) left, and there are 2 games going on between them. If one wins a game and loses the other game, he will be the winner but have 0 credits left in the report.