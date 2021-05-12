IMPORT FGL wc_2darray
GLOBALS "global.4gl"


FUNCTION do_pick()
DEFINE now DATETIME YEAR TO MINUTE
DEFINE localtime DATETIME YEAR TO MINUTE
DEFINE kickoff_utc DATETIME YEAR TO MINUTE
DEFINE sql STRING
DEFINE i INTEGER
TYPE pickType RECORD
    game INTEGER,
    team1 INTEGER,
    pick SMALLINT,
    team2 INTEGER,
    venue INTEGER,
    kickoff DATETIME YEAR TO MINUTE,
    gametype INTEGER,
    vn_stadium STRING,
    vn_city STRING,
    gt_value INTEGER,
    gt_drawallowed INTEGER,
    tm1_name STRING,
    tm1_colour1 CHAR(7),
    tm1_colour2 CHAR(7),
    tm1_flag CHAR(7),
    tm2_name STRING,
    tm2_colour1 CHAR(7),
    tm2_colour2 CHAR(7),
    tm2_flag CHAR(7)
END RECORD
DEFINE pick_rec pickType
DEFINE pick_arr DYNAMIC ARRAY OF pickType
DEFINE wc_pick STRING
DEFINE click_type STRING
DEFINE click_x INTEGER
DEFINE click_y INTEGER
DEFINE sg_arr DYNAMIC ARRAY OF RECORD
    game INT,
    flag1 STRING,
    team1 STRING,
    pick STRING,
    team2 STRING,
    flag2 STRING,
    venue STRING,
    kickoff STRING,
    gametype STRING,
    v1 STRING,
    dr STRING,
    v2 STRING
END RECORD
     

    LET now = get_now_utc()
    DISPLAY now
    LET sql = "SELECT gm_id, gm_team1, pk_pick, gm_team2, gm_venue, gm_kickoff, gm_gametype, vn_stadium, vn_city, gt_value, gt_drawallowed, ",
             "t1.tm_name, t1.tm_colour1, t1.tm_colour2, t1.tm_flag, ",
             "t2.tm_name, t2.tm_colour1, t2.tm_colour2, t2.tm_flag ",

             "FROM game ", 
             "LEFT OUTER JOIN pick ON game.gm_id = pick.pk_game AND pick.pk_login = ?  ",
             "LEFT OUTER JOIN venue ON game.gm_venue = venue.vn_id ",
             "LEFT OUTER JOIN gametype ON game.gm_gametype = gametype.gt_id ",
             "LEFT OUTER JOIN team t1 ON game.gm_team1 = t1.tm_id ",
             "LEFT OUTER JOIN team t2 ON game.gm_team2 = t2.tm_id ",
             "WHERE game.gm_kickoff > ? ",
             "ORDER BY gm_kickoff"

    DECLARE pick_curs CURSOR  FROM SQL
   {
    LET i = 0
    CALL wc_2darray.init()
    CALL wc_2darray.style_append(".picked","border","3px solid");
    CALL wc_2darray.style_append(".picked","border-color","black black black black");
    CALL wc_2darray.style_append(".picked","border-radius","5px");

    CALL wc_2darray.style_append(".row","height","2em");
    CALL wc_2darray.style_append(".center","text-align","center");

    CALL wc_2darray.col_set(1, "")
    CALL wc_2darray.col_set(2, "")
    CALL wc_2darray.col_set(3, "")
    CALL wc_2darray.col_set(4, "")
    CALL wc_2darray.col_set(5, "")
    CALL wc_2darray.col_set(6, "Picks")
    CALL wc_2darray.col_set(7, "Points")
    CALL wc_2darray.col_set(8, "Kick-off")
    CALL wc_2darray.col_set(9, "Venue")

    CALL wc_2darray.col_style_set(1,"width: 5%")
    CALL wc_2darray.col_style_set(2,"width: 20%")
    CALL wc_2darray.col_style_set(3,"width: 8%")
    CALL wc_2darray.col_style_set(4,"width: 20%")
    CALL wc_2darray.col_style_set(5,"width: 5%")
    CALL wc_2darray.col_style_set(6,"width: 5%")
    CALL wc_2darray.col_style_set(7,"width: 5%")
    CALL wc_2darray.col_style_set(8,"width: 14%")
    CALL wc_2darray.col_style_set(9,"width: 18%")

    
    FOREACH pick_curs USING login, now INTO pick_rec.*
        LET i = i + 1
        LET localtime = get_local_time(pick_rec.kickoff)
        CALL wc_2darray.row_set(i,"")
        CALL wc_2darray.row_class_set(i,"row")
        LET pick_arr[i].* = pick_rec.*
        
        CALL wc_2darray.cell_set(2,i,pick_rec.tm1_name)
        IF pick_rec.gt_drawallowed THEN
            CALL wc_2darray.cell_set(3,i,"Draw")
        ELSE
            CALL wc_2darray.cell_set(3,i,"versus")
        END IF
        CALL wc_2darray.cell_set(4,i,pick_rec.tm2_name)
        
        CALL wc_2darray.cell_set(6,i,"Picks") -- replace with img
        CALL wc_2darray.cell_set(7,i,pick_rec.gt_value)
        CALL wc_2darray.cell_set(8,i,localtime)
        CALL wc_2darray.cell_set(9,i,SFMT("%1 (%2)", pick_rec.vn_stadium, pick_rec.vn_city))

        CALL wc_2darray.cell_class_append(2,i,IIF(pick_rec.pick=1,"picked","not_picked"))
        CALL wc_2darray.cell_class_append(3,i,IIF(pick_rec.pick=0,"picked","not_picked"))
        CALL wc_2darray.cell_class_append(4,i,IIF(pick_rec.pick=-1,"picked","not_picked"))
        CALL wc_2darray.cell_class_append(2,i,"center")
        CALL wc_2darray.cell_class_append(3,i,"center")
        CALL wc_2darray.cell_class_append(4,i,"center")
        CALL wc_2darray.cell_class_append(6,i,"center")
        CALL wc_2darray.cell_class_append(7,i,"center")
        CALL wc_2darray.cell_class_append(8,i,"center")
        CALL wc_2darray.cell_class_append(9,i,"center")

        -- TODO: change background image depending on the host automatically
        CALL wc_2darray.cell_style_set(1,i,SFMT("background-image: url(https://demo.4js.com/gas/ua/i/flags/%1); background-size: %2",pick_rec.tm1_flag, "100% 100%"))
        CALL wc_2darray.cell_style_set(2,i,SFMT("background-color: %1; color: %2;","lightgrey", pick_rec.tm1_colour1))
        CALL wc_2darray.cell_style_set(4,i,SFMT("background-color: %1; color: %2;","lightgrey", pick_rec.tm2_colour1))
        CALL wc_2darray.cell_style_set(5,i,SFMT("background-image: url(https://demo.4js.com/gas/ua/i/flags/%1); background-size: %2",pick_rec.tm2_flag, "100% 100%"))
        
        IF pick_rec.tm1_colour2 IS NOT NULL THEN
            CALL wc_2darray.cell_style_append(2,i,SFMT("text-shadow: 0 0 2px %1;", pick_rec.tm1_colour2))
        END IF
        IF pick_rec.tm2_colour2 IS NOT NULL THEN
            CALL wc_2darray.cell_style_append(4,i,SFMT("text-shadow: 0 0 2px %1;", pick_rec.tm2_colour2))
        END IF
       
    END FOREACH
    }

    FOREACH pick_curs USING login, now INTO pick_rec.*
        LET i = i + 1
        LET localtime = get_local_time(pick_rec.kickoff)
        --CALL wc_2darray.row_set(i,"")
        --CALL wc_2darray.row_class_set(i,"row")
        LET pick_arr[i].* = pick_rec.*

        {
        CALL wc_2darray.cell_set(2,i,pick_rec.tm1_name)
        IF pick_rec.gt_drawallowed THEN
            CALL wc_2darray.cell_set(3,i,"Draw")
        ELSE
            CALL wc_2darray.cell_set(3,i,"versus")
        END IF
        CALL wc_2darray.cell_set(4,i,pick_rec.tm2_name)
        
        CALL wc_2darray.cell_set(6,i,"Picks") -- replace with img
        CALL wc_2darray.cell_set(7,i,pick_rec.gt_value)
        CALL wc_2darray.cell_set(8,i,localtime)
        CALL wc_2darray.cell_set(9,i,SFMT("%1 (%2)", pick_rec.vn_stadium, pick_rec.vn_city))

        CALL wc_2darray.cell_class_append(2,i,IIF(pick_rec.pick=1,"picked","not_picked"))
        CALL wc_2darray.cell_class_append(3,i,IIF(pick_rec.pick=0,"picked","not_picked"))
        CALL wc_2darray.cell_class_append(4,i,IIF(pick_rec.pick=-1,"picked","not_picked"))
        CALL wc_2darray.cell_class_append(2,i,"center")
        CALL wc_2darray.cell_class_append(3,i,"center")
        CALL wc_2darray.cell_class_append(4,i,"center")
        CALL wc_2darray.cell_class_append(6,i,"center")
        CALL wc_2darray.cell_class_append(7,i,"center")
        CALL wc_2darray.cell_class_append(8,i,"center")
        CALL wc_2darray.cell_class_append(9,i,"center")

        -- TODO: change background image depending on the host automatically
        CALL wc_2darray.cell_style_set(1,i,SFMT("background-image: url(https://demo.4js.com/gas/ua/i/flags/%1); background-size: %2",pick_rec.tm1_flag, "100% 100%"))
        CALL wc_2darray.cell_style_set(2,i,SFMT("background-color: %1; color: %2;","lightgrey", pick_rec.tm1_colour1))
        CALL wc_2darray.cell_style_set(4,i,SFMT("background-color: %1; color: %2;","lightgrey", pick_rec.tm2_colour1))
        CALL wc_2darray.cell_style_set(5,i,SFMT("background-image: url(https://demo.4js.com/gas/ua/i/flags/%1); background-size: %2",pick_rec.tm2_flag, "100% 100%"))
        
        IF pick_rec.tm1_colour2 IS NOT NULL THEN
            CALL wc_2darray.cell_style_append(2,i,SFMT("text-shadow: 0 0 2px %1;", pick_rec.tm1_colour2))
        END IF
        IF pick_rec.tm2_colour2 IS NOT NULL THEN
            CALL wc_2darray.cell_style_append(4,i,SFMT("text-shadow: 0 0 2px %1;", pick_rec.tm2_colour2))
        END IF
        }
       
    END FOREACH

    #Initialize display 
    FOR i = 1 TO pick_arr.getLength()
        SELECT tm_name INTO sg_arr[i].team1 FROM team, game WHERE gm_id = i AND tm_id = gm_team1
        SELECT tm_name INTO sg_arr[i].team2 FROM team, game WHERE gm_id = i AND tm_id = gm_team2
        SELECT tm_flag INTO sg_arr[i].flag1 FROM team, game WHERE gm_id = i AND tm_id = gm_team1
        SELECT tm_flag INTO sg_arr[i].flag2 FROM team, game WHERE gm_id = i AND tm_id = gm_team2
        SELECT vn_stadium INTO sg_arr[i].venue FROM venue, game WHERE gm_id = i AND vn_id = gm_venue
        SELECT gt_name INTO sg_arr[i].gametype FROM gametype, game WHERE gm_id = i AND gm_gametype = gt_id
        SELECT gm_kickoff INTO kickoff_utc FROM game WHERE gm_id = i
        LET localtime = get_local_time(kickoff_utc)
        LET sg_arr[i].kickoff = localtime
        LET sg_arr[i].v1 = "1.png"
        LET sg_arr[i].v2 = "2.png"
        LET sg_arr[i].dr = "x.png"
        
        
    END FOR

    DISPLAY sg_arr[1].team1
    
    OPEN WINDOW pick WITH FORM "pick_new"

    DISPLAY ARRAY sg_arr TO pick_scr.* 
        ON ACTION EXIT
        EXIT DISPLAY
    END DISPLAY

    {
    DIALOG ATTRIBUTES(UNBUFFERED)
        INPUT BY NAME wc_pick ATTRIBUTES(WITHOUT DEFAULTS=TRUE)
        
            ON ACTION select ATTRIBUTES(DEFAULTVIEW=NO)
                CALL get_click(wc_pick) RETURNING click_type, click_x, click_y
                IF click_type = "cell" AND click_x <=4 AND click_x >= 2 THEN
                    IF click_x = 3 AND NOT pick_arr[click_y].gt_drawallowed THEN
                        CALL FGL_WINMESSAGE("Error","Cannot select draw in knock-out games","stop")
                        NEXT FIELD CURRENT 
                    END IF
                
                    IF get_now_utc() > pick_arr[click_y].kickoff THEN
                        CALL FGL_WINMESSAGE("Error","Game has kicked off","stop")
                        NEXT FIELD CURRENT
                    END IF
                    
                    CALL update_pick(pick_arr[click_y].game, 3-click_x)
                    CALL wc_2darray.cell_class_set(2,click_y,IIF(click_x=2,"picked","not_picked"))
                    CALL wc_2darray.cell_class_set(3,click_y,IIF(click_x=3,"picked","not_picked"))
                    CALL wc_2darray.cell_class_set(4,click_y,IIF(click_x=4,"picked","not_picked"))
                    CALL wc_2darray.cell_class_append(2,click_y,"center")
                    CALL wc_2darray.cell_class_append(3,click_y,"center")
                    CALL wc_2darray.cell_class_append(4,click_y,"center")
                    CALL wc_2darray.html_send("formonly.wc_pick")
                END IF
                
                IF click_type = "cell" AND click_x = 6 THEN
                    CALL do_game_pick(pick_arr[click_y].game)
                END IF
        END INPUT
        
        BEFORE DIALOG
            CALL wc_2darray.html_send("formonly.wc_pick")
            
        ON ACTION close
            EXIT DIALOG

        ON ACTION cancel
            EXIT DIALOG
        
    END DIALOG
}
    
    CLOSE WINDOW pick

END FUNCTION


FUNCTION update_pick(l_game, l_pick)
DEFINE l_game, l_pick INTEGER

    BEGIN WORK

    UPDATE pick
    SET pk_pick = l_pick
    WHERE pk_login = login
    AND pk_game = l_game

    IF rows_updated() = 0 THEN
        INSERT INTO pick(pk_login, pk_game, pk_pick)
        VALUES(login, l_game, l_pick)
    END IF

    INSERT INTO pick_audit(pa_login, pa_game, pa_pick, pa_when) 
    VALUES(login, l_game, l_pick, CURRENT YEAR TO SECOND)

    COMMIT WORK
END FUNCTION