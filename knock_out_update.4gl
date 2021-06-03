MAIN
    
    CONNECT TO "sweep"
    
    CALL update_knock_out()
    
END MAIN

FUNCTION update_knock_out()
    WHENEVER ANY ERROR STOP
    -- Update des 1/8 de finales
{    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=37
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=38
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=39
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=40
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=41
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=42
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=43
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=44}
    -- Update des 1/4 de finales
{    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=45
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=46
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=47
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=48}
    -- Update des 1/2 de finales
{   UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=49
    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=50}
    -- Update des finales
{    UPDATE game SET gm_team1=, gm_team2= WHERE gm_id=51}
END FUNCTION
