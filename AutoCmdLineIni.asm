include advapi32.inc
includelib advapi32.lib

IniGetModuleCmdLine         PROTO :DWORD, :DWORD, :DWORD
IniSetModuleCmdLine         PROTO :DWORD, :DWORD, :DWORD

.CONST


.DATA


.DATA?


.CODE

IniGetModuleCmdLine PROC USES EBX lpszModuleFilename:DWORD, lpszCommandLine:DWORD, lpdwRememberOption:DWORD
    LOCAL szIniCommandLineString[MAX_PATH+2]:BYTE
    LOCAL lenModuleFilename:DWORD
    
    Invoke lstrlen, Addr DebugFilenameMD5
    .IF eax == 0 ; havnt got the hash of this module name yet, so do it now

        Invoke AutoCmdLineCreateHash, lpszModuleFilename, Addr DebugFilenameMD5
        
        Invoke lstrcpy, Addr szLogMsg, Addr szIniGetModuleCmdLine
        Invoke lstrcat, Addr szLogMsg, Addr DebugFilenameMD5
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
    
        IFDEF DEBUG32
        PrintText 'IniGetModuleCmdLine'
        PrintString DebugFilenameMD5
        ENDIF
    .ENDIF

    Invoke GetPrivateProfileString, Addr DebugFilenameMD5, Addr szIniCmdLine, Addr szColon, Addr szIniCommandLineString, SIZEOF szIniCommandLineString, Addr AutoCmdLineIni
    .IF eax == 0 || eax == 1 ; just got nothing or the colon and nothing else, so no command line stored for this
        mov ebx, lpszCommandLine
        mov byte ptr [ebx], 0
        mov eax, FALSE
    .ELSE
        Invoke GetPrivateProfileInt, Addr DebugFilenameMD5, Addr szIniRemember, 0, Addr AutoCmdLineIni
        mov ebx, lpdwRememberOption
        mov [ebx], eax
        
        Invoke lstrcpy, lpszCommandLine, Addr szQuote
        Invoke lstrcat, lpszCommandLine, Addr szIniCommandLineString
        Invoke lstrcat, lpszCommandLine, Addr szQuote
        ;Invoke lstrcpy, lpszCommandLine, Addr szIniCommandLineString
        mov eax, TRUE
    .ENDIF
    ret

IniGetModuleCmdLine endp



IniSetModuleCmdLine PROC USES EBX lpszModuleFilename:DWORD, lpszCommandLine:DWORD, dwRememberOption:DWORD
    LOCAL szIniCommandLineString[MAX_PATH]:BYTE
    LOCAL lenModuleFilename:DWORD

    Invoke AutoCmdLineCreateHash, lpszModuleFilename, Addr DebugFilenameMD5
        
    Invoke lstrcpy, Addr szLogMsg, Addr szIniSetModuleCmdLine
    Invoke lstrcat, Addr szLogMsg, Addr DebugFilenameMD5
    Invoke lstrcat, Addr szLogMsg, Addr szSpace
    Invoke lstrcat, Addr szLogMsg, lpszModuleFilename
    Invoke lstrcat, Addr szLogMsg, Addr szCRLF
    Invoke GuiAddLogMessage, Addr szLogMsg        
    
    IFDEF DEBUG32
    PrintText 'IniSetModuleCmdLine'
    PrintString DebugFilenameMD5
    ENDIF

    
    Invoke WritePrivateProfileString, Addr DebugFilenameMD5, Addr szIniCmdLine, lpszCommandLine, Addr AutoCmdLineIni
    .IF dwRememberOption == 0
        Invoke WritePrivateProfileString, Addr DebugFilenameMD5, Addr szIniRemember, Addr szZero, Addr AutoCmdLineIni
    .ELSE
        Invoke WritePrivateProfileString, Addr DebugFilenameMD5, Addr szIniRemember, Addr szOne, Addr AutoCmdLineIni
    .ENDIF
    ret

IniSetModuleCmdLine endp

