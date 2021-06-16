TYPE player_pick_rowType RECORD
game INTEGER,
team1 CHAR(20),
pick INTEGER,
team2 CHAR(20),
venue STRING,
kickoff DATETIME YEAR TO MINUTE
END RECORD

FUNCTION do_player_pick(player_login)
DEFINE player_login CHAR(10)
DEFINE player RECORD
   login CHAR(10),
   firstname CHAR(30),
   surname CHAR(30)
END RECORD
DEFINE sql STRING
DEFINE i INTEGER
DEFINE stadium, city CHAR(30)
DEFINE player_pick_row player_pick_rowType
DEFINE player_pick_row_new RECORD
    game INTEGER,
    team1 CHAR(20),
    pick INTEGER,
    team2 CHAR(20),
    score1 INTEGER,
    score2 INTEGER,
    result CHAR(10),
    kickoff DATETIME YEAR TO MINUTE
END RECORD
DEFINE player_pick_arr DYNAMIC ARRAY OF player_pick_rowType
DEFINE player_pick_arr_new DYNAMIC ARRAY OF RECORD
    game INTEGER,
    team1 CHAR(20),
    pick INTEGER,
    team2 CHAR(20),
    score1 INTEGER,
    score2 INTEGER,
    result CHAR(10),
    kickoff DATETIME YEAR TO MINUTE
END RECORD
DEFINE localtime DATETIME YEAR TO MINUTE
DEFINE now DATETIME YEAR TO MINUTE


   OPEN WINDOW player_pick WITH FORM "player_pick"
   LET player.login= player_login

   LET now = get_now_utc()
   
   LET sql = "SELECT pl_firstname, pl_surname ",
             "FROM player ",
             "WHERE pl_login = ? "

   DECLARE player_curs CURSOR FROM sql
   OPEN player_curs USING player.login
   FETCH player_curs INTO player.firstname, player.surname

   DISPLAY player.login TO login
   DISPLAY SFMT("%1 %2", player.firstname CLIPPED, player.surname CLIPPED ) TO name;

   LET sql = "SELECT gm_id, gm_team1, pk_pick, gm_team2, gm_score1, gm_score2, pk_point, gm_kickoff ",
             "FROM game LEFT OUTER JOIN pick ON game.gm_id = pick.pk_game AND pick.pk_login = ? ",
             "WHERE pick.pk_login = ? ",
             "AND pk_game = gm_id ",
             "AND game.gm_kickoff < ?",
             "ORDER BY gm_id "

   DECLARE player_pick_curs CURSOR FROM sql
   LET i = 0
   CALL player_pick_arr.clear()
   FOREACH player_pick_curs USING player.login, player.login, now INTO player_pick_row_new.*
      LET i = i + 1
      LET localtime = get_local_time(player_pick_row_new.kickoff)
      LET player_pick_arr_new[i].*= player_pick_row_new.*
      LET player_pick_arr_new[i].kickoff = localtime
      DISPLAY  player_pick_arr_new[i].result
      IF  player_pick_arr_new[i].result > 0 THEN
         LET player_pick_arr_new[i].result = "accept"
      ELSE
         LET player_pick_arr_new[i].result = "cancel"
      END IF
   END FOREACH

   DIALOG
      DISPLAY ARRAY player_pick_arr_new TO player_pick_scr.*
      END DISPLAY
      ON ACTION back_dialog
          EXIT DIALOG
   END DIALOG
   CLOSE WINDOW player_pick
END FUNCTION

   
