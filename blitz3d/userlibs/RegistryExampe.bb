;
; RegistryDLL Example.bb
;
 

; pre-defined reg keys.
HKEY_CLASSES_ROOT 	  = 1	
HKEY_CURRENT_USER	  = 2
HKEY_LOCAL_MACHINE 	  = 3
HKEY_USERS 			  = 4	
HKEY_PERFORMANCE_DATA = 5	
HKEY_CURRENT_CONFIG   = 6	
HKEY_DYN_DATA	      = 7


Function RegisterSchema()
    ; Define key and value information
    rootKey$ = "HKCU"
    schemaKey$ = "Software\Classes\smmm"
    shellCommandKey$ = "Software\Classes\smmm\shell\open\command"
    commandValue$ = Chr(34) + AppDir() + Chr(34) + " %1"
    
    ; Create the schema association
    SETRegistryValue(2, rootKey$, schemaKey$, "URL:smmm Protocol") ; Default value
    SETRegistryValue(2, rootKey$, schemaKey$ + "\URL Protocol", "") ; Empty string
    SETRegistryValue(2, rootKey$, shellCommandKey$, commandValue$) ; Command to run the installer
End Function
