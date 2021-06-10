GLOBALS "global.4gl"

FUNCTION do_rules()
DEFINE rules TEXT

   OPEN WINDOW rules WITH FORM "rules"  
   LOCATE rules IN FILE "rules.txt"
   DISPLAY BY NAME rules
   
   MENU ""
      ON ACTION back_dialog
         EXIT MENU
   END MENU

   CLOSE WINDOW rules
END FUNCTION
