TYPE leaderboardType RECORD
   login CHAR(10),
   name CHAR(40),
   score INTEGER,
   rank INTEGER
END RECORD

DEFINE leaderboard_arr DYNAMIC ARRAY OF leaderboardType
DEFINE leaderboard_row leaderboardType

FUNCTION do_leaderboard()
   OPEN WINDOW leaderboard WITH FORM "leaderboard"

   CALL get_leaderboard()

   -- replace with ON FILL if entries get large
   DISPLAY ARRAY leaderboard_arr TO leaderboard_scr.* ATTRIBUTES (DOUBLECLICK=player_pick, ACCEPT=FALSE, CANCEL=FALSE)      
      BEFORE DISPLAY
         CALL setup_dialog(DIALOG)

      --ON ACTION result
         --CALL do_result(leaderboard_arr[DIALOG.getCurrentRow("leaderboard_scr")].login)

      ON ACTION player_pick
         CALL do_player_pick(leaderboard_arr[DIALOG.getCurrentRow("leaderboard_scr")].login)

      ON ACTION back_dialog
         EXIT DISPLAY
   END DISPLAY

   CLOSE WINDOW leaderboard
END FUNCTION

PRIVATE FUNCTION setup_dialog(d ui.Dialog)
DEFINE has_rows BOOLEAN
--DEFINE is_superuser BOOLEAN
    LET has_rows = leaderboard_arr.getLength()>0 
    --CALL d.setActionActive("result", has_rows)
    CALL d.setActionActive("player_pick", has_rows)

END FUNCTION 


PRIVATE FUNCTION get_leaderboard()
DEFINE sql STRING
DEFINE firstname, surname CHAR(30)
DEFINE i INTEGER

   LET sql = "SELECT pl_login, '', pl_score, pl_rank, pl_firstname, pl_surname ",
             "FROM player ",
             "WHERE pl_login != 'admin' ",
             "ORDER BY pl_rank, pl_login "

   DECLARE leaderboard_curs CURSOR FROM sql

   CALL leaderboard_arr.clear()
   LET i = 0
   FOREACH leaderboard_curs INTO leaderboard_row.*, firstname, surname
      LET leaderboard_row.name= SFMT("%1 %2", firstname CLIPPED, surname CLIPPED)
      LET i = i + 1
      LET leaderboard_arr[i].*=leaderboard_row.*
   END FOREACH
END FUNCTION
