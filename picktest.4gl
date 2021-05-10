GLOBALS "global.4gl"

main
TYPE pickType RECORD
    game INTEGER,
    flag_team1 STRING,
    team1 STRING,
    drawallowed STRING,
    team2 STRING,
    flag_team2 STRING,
    picks INTEGER,
    gametype INTEGER,
    kickoff DATETIME YEAR TO MINUTE,
    venue STRING 
--    gt_value INTEGER,
--    tm1_colour1 CHAR(7),
--    tm1_colour2 CHAR(7),
--    tm2_colour1 CHAR(7),
--    tm2_colour2 CHAR(7)
END RECORD
DEFINE now DATETIME YEAR TO MINUTE
DEFINE stadium STRING
DEFINE city STRING
DEFINE sql STRING
DEFINE i INTEGER
DEFINE pick_rec pickType
DEFINE pick_arr DYNAMIC ARRAY OF pickType

CONNECT TO "sweep"

OPEN WINDOW picktest WITH FORM "picktest"
    LET now = get_now_utc()
    LET sql = "SELECT gm_id, t1.tm_colour1, t1.tm_name, gt_drawallowed, t2.tm_name, t2.tm_colour1, pk_pick, gt_value, gm_kickoff, gm_venue, vn_stadium , vn_city ",
             "FROM game ", 
             "LEFT OUTER JOIN pick ON game.gm_id = pick.pk_game ",
             "LEFT OUTER JOIN venue ON game.gm_venue = venue.vn_id ",
             "LEFT OUTER JOIN gametype ON game.gm_gametype = gametype.gt_id ",
             "LEFT OUTER JOIN team t1 ON game.gm_team1 = t1.tm_id ",
             "LEFT OUTER JOIN team t2 ON game.gm_team2 = t2.tm_id ",
             "WHERE game.gm_kickoff > ? ",
             "ORDER BY gm_kickoff"

DECLARE pick_curs CURSOR FROM sql

   LET i = 0
   FOREACH pick_curs USING now INTO pick_rec.*, stadium, city
   LET i = i + 1
        LET pick_rec.kickoff = get_local_time(pick_rec.kickoff)
        LET pick_rec.venue = SFMT("%1 (%2)", stadium CLIPPED, city CLIPPED)
        IF pick_rec.drawallowed THEN
            LET pick_rec.drawallowed="Draw"
        ELSE
            LET pick_rec.drawallowed="Versus"
        END IF
        LET pick_arr[i].* = pick_rec.*
   END FOREACH
             
DIALOG ATTRIBUTE (UNBUFFERED)
      DISPLAY ARRAY pick_arr TO pick_scr.*
      END DISPLAY
      
      ON ACTION cancel
         EXIT DIALOG
         
      ON ACTION close
         EXIT PROGRAM 1
   END DIALOG 

   CLOSE WINDOW picktest

END main