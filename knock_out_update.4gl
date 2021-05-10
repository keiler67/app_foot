MAIN
    
    CONNECT TO "sweep"
    
    CALL update_knock_out()
    
END MAIN

FUNCTION update_knock_out()
    WHENEVER ANY ERROR STOP
    -- Update des 1/8 de finales
    UPDATE game SET gm_team1=4, gm_team2=5 WHERE gm_id=49
    UPDATE game SET gm_team1=9, gm_team2=13 WHERE gm_id=50
    UPDATE game SET gm_team1=6, gm_team2=1 WHERE gm_id=51
    UPDATE game SET gm_team1=15, gm_team2=12 WHERE gm_id=52
    UPDATE game SET gm_team1=17, gm_team2=22 WHERE gm_id=53
    -- UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=54
    UPDATE game SET gm_team1=23, gm_team2=18 WHERE gm_id=55
    -- UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=56
    -- Update des 1/4 de finales
{    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=57
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=58
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=59
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=60}
    -- Update des 1/2 de finales
{    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=61
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=62}
    -- Update des finales
{    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=63
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=64}
END FUNCTION
