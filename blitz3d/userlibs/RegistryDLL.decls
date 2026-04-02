;
; Declarations file for RegistryDLL.dll
;
; Adds the following commands:


.lib "RegistryDLL.dll"
GETRegistryValue%(bank*,hKey%,RootKey$,SubKey$,Value$):"InsertRegistry"
SETRegistryValue%(hKey%,RootKey$,SubKey$,Value$):"SetRegistry"
DELRegistry%(hKey%,hKey%,RootKey$):"RemoveRegistry"
