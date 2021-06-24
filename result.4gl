GLOBALS "global.4gl"

TYPE resultType RECORD
   game INTEGER,
   team1 INTEGER,
   pick INTEGER,
   team2 INTEGER,
   score1 INTEGER,
   score2 INTEGER,
   result CHAR(10),
   kickoff DATETIME YEAR TO MINUTE
END RECORD

FUNCTION do_result(l_login)
DEFINE result_rec resultType
DEFINE result_arr DYNAMIC ARRAY OF resultType
DEFINE sql STRING
DEFINE i INTEGER
DEFINE now DATETIME YEAR TO MINUTE
DEFINE l_login CHAR(10)
DEFINE localtime DATETIME YEAR TO MINUTE

   OPEN WINDOW result WITH FORM "result"

   LET now = get_now_utc()

   LET sql = "SELECT gm_id, gm_team1, pk_pick, gm_team2, gm_score1, gm_score2, pk_point, gm_kickoff ",
             "FROM game LEFT OUTER JOIN pick ON game.gm_id = pick.pk_game AND pick.pk_login = ? ",
             --"WHERE game.gm_kickoff < ? ",
             "ORDER BY gm_kickoff"

   DECLARE result_curs CURSOR  FROM sql

   LET i = 0
   FOREACH result_curs USING l_login INTO result_rec.*
      LET i = i + 1
      LET result_arr[i].* = result_rec.*
      LET localtime = get_local_time(result_rec.kickoff)
      LET result_arr[i].kickoff = localtime
      IF result_arr[i].result > 0 THEN
         LET result_arr[i].result = "accept"
      ELSE
         LET result_arr[i].result = "cancel"
      END IF
   END FOREACH

   --DIALOG
      DISPLAY ARRAY result_arr TO result_scr.* ATTRIBUTES (ACCEPT=FALSE, CANCEL=FALSE)
        BEFORE DISPLAY
            CALL DIALOG.setActionActive("game_pick", result_arr.getLength()>0)
            FOR i = 1 TO result_arr.getLength() 
                 IF result_arr[i].score1 IS NULL AND result_arr[i].score2 IS NULL THEN
                     LET result_arr[i].result = "fa-minus"   
                 END IF
            END FOR
                

        BEFORE ROW 
            IF result_arr[arr_curr()].score1 IS NULL AND result_arr[arr_curr()].score2 IS NULL THEN
                CALL DIALOG.setActionActive("game_pick", 0) ELSE
                CALL DIALOG.setActionActive("game_pick", 1)
            END IF
            
        ON ACTION game_pick
            CALL do_game_pick(result_arr[DIALOG.getCurrentRow("result_scr")].game)
      
        ON ACTION back_dialog
            EXIT DISPLAY
         
        ON ACTION CLOSE
            EXIT PROGRAM 1
      END DISPLAY      
   --END DIALOG 

   CLOSE WINDOW result

END FUNCTION
