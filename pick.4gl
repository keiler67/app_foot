--IMPORT FGL wc_2darray
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
    city STRING,
    kickoff STRING,
    gametype STRING,
    v1 STRING,
    dr STRING,
    v2 STRING
END RECORD
DEFINE w ui.Window
DEFINE f ui.Form
DEFINE n om.DomNode
DEFINE nlist om.NodeList

     

    
        

    LET now = get_now_utc()
    DISPLAY "NOW IS ", now
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

    FOREACH pick_curs USING login, now INTO pick_rec.*
        LET i = i + 1
        LET localtime = get_local_time(pick_rec.kickoff)
        LET pick_arr[i].* = pick_rec.*       
    END FOREACH

    #Initialize display 
    FOR i = 1 TO pick_arr.getLength()
        LET sg_arr[i].game = pick_arr[i].game
        LET sg_arr[i].team1 = pick_arr[i].tm1_name
        LET sg_arr[i].team2 = pick_arr[i].tm2_name
        LET sg_arr[i].flag1 = pick_arr[i].tm1_flag
        LET sg_arr[i].flag2 = pick_arr[i].tm2_flag
        LET sg_arr[i].venue = pick_arr[i].vn_stadium
        LET sg_arr[i].city = pick_arr[i].vn_city
        SELECT gt_name INTO sg_arr[i].gametype FROM gametype WHERE gt_id = pick_arr[i].gametype
        LET kickoff_utc = pick_arr[i].kickoff
        LET localtime = get_local_time(kickoff_utc)
        LET sg_arr[i].kickoff = localtime  


        #Handle games already bat 
        IF pick_arr[i].pick = 1 THEN 
            LET sg_arr[i].v1 = "1_validate.png" ELSE
            LET sg_arr[i].v1 = "1.png"
        END IF

        IF pick_arr[i].pick = -1 THEN 
            LET sg_arr[i].v2 = "2_validate.png" ELSE
            LET sg_arr[i].v2 = "2.png"
        END IF

        IF pick_arr[i].pick = 0 THEN
            LET sg_arr[i].dr = "x_validate.png" ELSE
            LET sg_arr[i].dr = "x.png"
        END IF
        
         #Handle if draw allowed or not
        IF NOT pick_arr[i].gt_drawallowed THEN
            LET sg_arr[i].dr = NULL 
        END IF
    
    END FOR
    
    OPEN WINDOW pick WITH FORM "pick_new"

    DISPLAY "MEDIA IS ", ui.Interface.getRootNode().getAttribute("media")

     #pagedScrollgrid for media = medium and large and NULL (attribute not initialized on GBC/GMA/GMI initial display) + GMI / 
     
     IF ui.Interface.getRootNode().getAttribute("media") == "large" OR
     ui.Interface.getRootNode().getAttribute("media") == "medium" OR
     ui.Interface.getFrontEndName() == "GBC"
     THEN  
        DISPLAY "MEDIA CONDITION OK"
        DISPLAY ui.Interface.getFrontEndName()
        LET w = ui.Window.getCurrent()
        LET f = w.getForm()
        CALL f.setElementStyle("sg1", "paged")
     END IF
    
    DISPLAY ARRAY sg_arr TO pick_scr.* ATTRIBUTES (UNBUFFERED, DOUBLECLICK=pick_details, ACCEPT=FALSE, CANCEL=FALSE)
        ON ACTION win1 
            CASE sg_arr[arr_curr()].v1
                #If v1 is already selected, need to select another pick (if you want to update)
                #delete is not allowed
                WHEN "1_validate.png"
                      ERROR "Pick already selected, choose another pick"
                WHEN "1.png" 
                    IF sg_arr[arr_curr()].v2 = "2_validate.png" THEN 
                        LET sg_arr[arr_curr()].v2 = "2.png"
                    END IF
                    IF sg_arr[arr_curr()].dr = "x_validate.png" THEN 
                        LET sg_arr[arr_curr()].dr = "x.png"
                    END IF
                    LET sg_arr[arr_curr()].v1 = "1_validate.png"
                    CALL update_pick(sg_arr[arr_curr()].game, 1)
            END CASE 

        ON ACTION win2 
            CASE sg_arr[arr_curr()].v2
                #If v1 is already selected, reset to unselected 
                WHEN "2_validate.png"
                      ERROR "Pick already selected, choose another pick"
                WHEN "2.png" 
                    IF sg_arr[arr_curr()].v1 = "1_validate.png" THEN 
                        LET sg_arr[arr_curr()].v1 = "1.png"
                    END IF
                    IF sg_arr[arr_curr()].dr = "x_validate.png" THEN 
                        LET sg_arr[arr_curr()].dr = "x.png"
                    END IF
                    LET sg_arr[arr_curr()].v2 = "2_validate.png"
                    CALL update_pick(sg_arr[arr_curr()].game, -1)
            END CASE  

        ON ACTION dr 
            CASE sg_arr[arr_curr()].dr
                #If v1 is already selected, reset to unselected 
                WHEN "x_validate.png"
                    ERROR "Pick already selected, choose another pick"
                WHEN "x.png" 
                    IF sg_arr[arr_curr()].v1 = "1_validate.png" THEN 
                        LET sg_arr[arr_curr()].v1 = "1.png"
                    END IF
                    IF sg_arr[arr_curr()].v2 = "2_validate.png" THEN 
                        LET sg_arr[arr_curr()].v2 = "2.png"
                    END IF
                    LET sg_arr[arr_curr()].dr = "x_validate.png"
                    CALL update_pick(sg_arr[arr_curr()].game, 0)
            END CASE
        ON ACTION pick_details  
                   CALL do_game_pick (sg_arr[arr_curr()].game)
        ON ACTION back_dialog 
                    EXIT DISPLAY

    END DISPLAY
    
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