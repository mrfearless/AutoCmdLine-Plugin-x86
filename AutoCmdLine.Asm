;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2016 - www.LetTheLight.in
;
; AutoCmdLine.asm
; 
; v1.0.0.2 - Last updated: 01/03/2016 
;
; - Added function AutoCmdLineLoadMenuIcon to load png resource image as raw bytes 
; - Added menu icon for plugin (uses _plugin_menuseticon)
;
;-------------------------------------------------------------------------------------

.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

;DEBUG32 EQU 1

IFDEF DEBUG32
    PRESERVEXMMREGS equ 1
    includelib M:\Masm32\lib\Debug32.lib
    DBG32LIB equ 1
    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
    include M:\Masm32\include\debug32.inc
ENDIF


Include x64dbgpluginsdk.inc                 ; Main x64dbg Plugin SDK for your program, and prototypes for the main exports 

Include AutoCmdLine.inc                     ; plugin's include file
Include AutoCmdLineIni.asm

pluginit	        PROTO C :DWORD          ; Required prototype and export for x64dbg plugin SDK
plugstop            PROTO C                 ; Required prototype and export for x64dbg plugin SDK
plugsetup           PROTO C :DWORD          ; Required prototype and export for x64dbg plugin SDK
;=====================================================================================


.CONST
PLUGIN_VERSION      EQU 1

.DATA
PLUGIN_NAME         DB "AutoCmdLine",0

.DATA?
;-------------------------------------------------------------------------------------
; GLOBAL Plugin SDK variables
;-------------------------------------------------------------------------------------
PUBLIC              pluginHandle
PUBLIC              hwndDlg
PUBLIC              hMenu
PUBLIC              hMenuDisasm
PUBLIC              hMenuDump
PUBLIC              hMenuStack

pluginHandle        DD ?
hwndDlg             DD ?
hMenu               DD ?
hMenuDisasm         DD ?
hMenuDump           DD ?
hMenuStack          DD ?
;-------------------------------------------------------------------------------------


.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllEntry PROC hInst:HINSTANCE, reason:DWORD, reserved:DWORD
    .IF reason == DLL_PROCESS_ATTACH
        mov eax, hInst
        mov hInstance, eax
    .ENDIF
    mov eax,TRUE
    ret
DllEntry Endp


;=====================================================================================
; pluginit - Called by debugger when plugin.dp32 is loaded - needs to be EXPORTED
; 
; Arguments: initStruct - a pointer to a PLUG_INITSTRUCT structure
;
; Notes:     you must fill in the pluginVersion, sdkVersion and pluginName members. 
;            The pluginHandle is obtained from the same structure - it may be needed in
;            other function calls.
;
;            you can call your own setup routine from within this function to setup 
;            menus and commands, and pass the initStruct parameter to this function.
;
;-------------------------------------------------------------------------------------
pluginit PROC C PUBLIC USES EBX initStruct:DWORD
    mov ebx, initStruct

    ; Fill in required information of initStruct, which is a pointer to a PLUG_INITSTRUCT structure
    mov eax, PLUGIN_VERSION
    mov [ebx].PLUG_INITSTRUCT.pluginVersion, eax
    mov eax, PLUG_SDKVERSION
    mov [ebx].PLUG_INITSTRUCT.sdkVersion, eax
    Invoke lstrcpy, Addr [ebx].PLUG_INITSTRUCT.pluginName, Addr PLUGIN_NAME
    
    mov ebx, initStruct
    mov eax, [ebx].PLUG_INITSTRUCT.pluginHandle
    mov pluginHandle, eax
    
    ; Do any other initialization here

    ; Construct plugin's .ini file from module filename
    Invoke GetModuleFileName, hInstance, Addr AutoCmdLineIni, SIZEOF AutoCmdLineIni
    Invoke lstrlen, Addr AutoCmdLineIni
    lea ebx, AutoCmdLineIni
    add ebx, eax
    sub ebx, 4 ; move back past 'dp32' extention
    mov byte ptr [ebx], 0 ; null so we can use lstrcat
    Invoke lstrcat, ebx, Addr szIni ; add 'ini' to end of string instead

    Invoke LoadIcon, hInstance, ICO_AUTOCMDLINE
    mov hIcoAutoCmdLine, eax

	mov eax, TRUE
	ret
pluginit endp


;=====================================================================================
; plugstop - Called by debugger when the plugin.dp32 is unloaded - needs to be EXPORTED
;
; Arguments: none
; 
; Notes:     perform cleanup operations here, clearing menus and other housekeeping
;
;-------------------------------------------------------------------------------------
plugstop PROC C PUBLIC 
    
    ; remove any menus, unregister any callbacks etc
    Invoke _plugin_menuclear, hMenu
    Invoke GuiAddLogMessage, Addr szPluginUnloaded
    
    mov eax, TRUE
    ret
plugstop endp


;=====================================================================================
; plugsetup - Called by debugger to initialize your plugins setup - needs to be EXPORTED
;
; Arguments: setupStruct - a pointer to a PLUG_SETUPSTRUCT structure
; 
; Notes:     setupStruct contains useful handles for use within x64_dbg, mainly Qt 
;            menu handles (which are not supported with win32 api) and the main window
;            handle with this information you can add your own menus and menu items 
;            to an existing menu, or one of the predefined supported right click 
;            context menus: hMenuDisam, hMenuDump & hMenuStack
;            
;            plugsetup is called after pluginit. 
;-------------------------------------------------------------------------------------
plugsetup PROC C PUBLIC USES EBX setupStruct:DWORD
    LOCAL hIconData:ICONDATA
    
    mov ebx, setupStruct

    ; Extract handles from setupStruct which is a pointer to a PLUG_SETUPSTRUCT structure  
    mov eax, [ebx].PLUG_SETUPSTRUCT.hwndDlg
    mov hwndDlg, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenu
    mov hMenu, eax
    ;PrintText 'AutoCmdLine'
    ;PrintDec hMenu
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuDisasm
    mov hMenuDisasm, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuDump
    mov hMenuDump, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuStack
    mov hMenuStack, eax

    Invoke GuiGetWindowHandle
    mov hwndDlg, eax
    
    ; Do any setup here: add menus, menu items, callback and commands etc
    Invoke GuiAddLogMessage, Addr szAutoCmdLineInfo ;szPluginLoaded
    Invoke _plugin_menuaddentry, hMenu, MENU_PLUGIN1, Addr szMenuPlugin1
    
    Invoke AutoCmdLineLoadMenuIcon, IMG_AUTOCMDLINE, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuseticon, hMenu, Addr hIconData
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_PLUGIN1, Addr hIconData
    .ENDIF

    
    ret
plugsetup endp


;=====================================================================================
; CBMENUENTRY - Called by debugger when a menu item is clicked - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_MENUENTRY structure. The hEntry contains 
;            the resource id of menu item identifiers
;  
; Notes:     hEntry can be used to determine if the user has clicked on your plugins
;            menu item(s) and to do something in response to it.
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBMENUENTRY PROC C PUBLIC USES EBX cbType:DWORD, cbInfo:DWORD
    mov ebx, cbInfo
    mov eax, [ebx].PLUG_CB_MENUENTRY.hEntry
    
    .IF eax == MENU_PLUGIN1
        Invoke DbgIsDebugging
        .IF eax == FALSE
            Invoke GuiAddStatusBarMessage, Addr szDebuggingRequired
            Invoke GuiAddLogMessage, Addr szDebuggingRequired
            ret
        .ELSE
            Invoke DialogBoxParam, hInstance, IDD_AddCmdLine, hwndDlg, Offset AddCmdLineDlgProc, NULL
        .ENDIF
    .ENDIF
    
    ret

CBMENUENTRY endp


;=====================================================================================
; CBINITDEBUG - Called by debugger when a program is debugged - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_INITDEBUG structure. 
;            The szFileName item contains name of file being debugged. 
;  
; Notes:     
;            
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBINITDEBUG PROC C PUBLIC USES EBX cbType:DWORD, cbInfo:DWORD
    ;LOCAL lenFilename:DWORD
    LOCAL lpszFilename:DWORD
    
    Invoke RtlZeroMemory, Addr DebugFilenameMD5, SIZEOF DebugFilenameMD5

    mov ebx, cbInfo
    mov eax, [ebx]
    mov DebugFilename, eax
    mov lpszFilename, eax
    ;Invoke lstrlen, lpszFilename
    ;mov lenFilename, eax

    Invoke AutoCmdLineCreateHash, lpszFilename, Addr DebugFilenameMD5
	;invoke MD5_Startup
	;invoke MD5_Init, offset dbgfilename_md5ctext
	;invoke MD5_Read, offset dbgfilename_md5ctext, lpszFilename, lenFilename
	;invoke MD5_Digest, offset dbgfilename_md5ctext, offset dbgfilename_md5chash
	;invoke MD52StringA, offset dbgfilename_md5chash, offset DebugFilenameMD5, 1
    
    mov eax, TRUE
    ret

CBINITDEBUG endp


;=====================================================================================
; CBSYSTEMBREAKPOINT - Called by debugger at system breakpoint - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - reserved 
;            
;  
; Notes:     
;            
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBSYSTEMBREAKPOINT PROC C PUBLIC cbType:DWORD, cbInfo:DWORD
    Invoke GuiSelectionGet, GUI_DISASSEMBLY, Addr sel
    _DbgFunctions ModPathFromAddr, sel.start, Addr szModuleFilename, MAX_PATH

    Invoke IniGetModuleCmdLine, Addr szModuleFilename, Addr szNewCommandLine, Addr dwRemember
    .IF eax == TRUE ; found it
        .IF dwRemember == 1 ; we fetch saved command line
            ; add entry into log to say cmd line has been changed
            Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
            Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineAutoChange
            Invoke lstrcat, Addr szLogMsg, Addr szNewCommandLine
            Invoke lstrcat, Addr szLogMsg, Addr szCRLF
            Invoke GuiAddLogMessage, Addr szLogMsg
        
            ; do the call to setcmdline
            Invoke lstrcat, Addr szNewCommandLine, Addr szCRLF
            _DbgFunctions SetCmdline, Addr szNewCommandLine
        .ENDIF
    .ENDIF    
    
    mov eax, TRUE
    ret
CBSYSTEMBREAKPOINT ENDP


;=====================================================================================
; AddCmdLineDlgProc Dialog Procedure
;-------------------------------------------------------------------------------------
AddCmdLineDlgProc PROC hWin:HWND,iMsg:DWORD,wParam:WPARAM, lParam:LPARAM
    LOCAL dwNewRemember:DWORD
    
    
    mov eax, iMsg
    .IF eax == WM_INITDIALOG
        ; Any initialization here
        
        Invoke SendMessage, hWin, WM_SETICON, ICON_SMALL, hIcoAutoCmdLine
        
        ; Get some information to set in dialogbox textboxes and our checkbox
        ;Invoke GuiSelectionGet, GUI_DISASSEMBLY, Addr sel
        ;_DbgFunctions ModPathFromAddr, sel.start, Addr szModuleFilename, MAX_PATH
        Invoke SetDlgItemText, hWin, IDC_TxtAddCmdLineModuleFilename, DebugFilename ; Addr szModuleFilename
        
        ; Search our ini file for a module that matches (using md5 hash of the full path name of file)
        Invoke IniGetModuleCmdLine, Addr szModuleFilename, Addr szCommandLine, Addr dwRemember
        .IF eax == FALSE ; we didnt find it in our ini file, so fetch current command line
            ; ok, so we just get the default cmdline instead and present that to our user.
            mov eax, 1024d
            mov dwCmdLineSize, eax
            _DbgFunctions GetCmdline, Addr szCommandLine, Addr dwCmdLineSize
            Invoke SendDlgItemMessage, hWin, IDC_ChkAddCmdLineRemember, BM_SETCHECK, BST_UNCHECKED, 0
             
        .ELSE ; we did find it
            .IF dwRemember == 0
                Invoke SendDlgItemMessage, hWin, IDC_ChkAddCmdLineRemember, BM_SETCHECK, BST_UNCHECKED, 0
            .ELSE
                Invoke SendDlgItemMessage, hWin, IDC_ChkAddCmdLineRemember, BM_SETCHECK, BST_CHECKED, 0
            .ENDIF
        .ENDIF
        Invoke SetDlgItemText, hWin, IDC_TxtAddCmdLineCommandLine, Addr szCommandLine
        
	.ELSEIF eax == WM_CLOSE
        Invoke EndDialog, hWin, NULL
        
	.ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == IDC_BtnAddCmdLineOK
            
            ; get text from command line textbox and get checkbox option
            Invoke RtlZeroMemory, Addr szNewCommandLine, SIZEOF szNewCommandLine
            Invoke GetDlgItemText, hWin, IDC_TxtAddCmdLineCommandLine, Addr szNewCommandLine, SIZEOF szNewCommandLine
            Invoke SendDlgItemMessage, hWin, IDC_ChkAddCmdLineRemember, BM_GETCHECK, 0, 0
            .IF eax == BST_CHECKED
                mov dwNewRemember, 1
            .ELSE
                mov dwNewRemember, 0
            .ENDIF
            
            ; save info to our ini file
            Invoke IniSetModuleCmdLine, DebugFilename, Addr szNewCommandLine, dwNewRemember ;Addr szModuleFilename
            
            ; add entry into log to say cmd line has been changed
            .IF dwRemember == 0 && dwNewRemember == 1 ; we are now set to remember so log msg reflects this
                Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
                Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineRemember
                Invoke lstrcat, Addr szLogMsg, Addr szNewCommandLine
                Invoke lstrcat, Addr szLogMsg, Addr szCRLF
                Invoke GuiAddLogMessage, Addr szLogMsg
            
            .ELSEIF dwRemember == 1 && dwNewRemember == 0 ; set to forget it
                Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
                Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineForgotten
                Invoke lstrcat, Addr szLogMsg, Addr szQ
                Invoke lstrcat, Addr szLogMsg, Addr szCRLF
                Invoke GuiAddLogMessage, Addr szLogMsg
            .ELSE
                ; otherwise we just changed command line
                Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
                Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineManualChange
                Invoke lstrcat, Addr szLogMsg, Addr szNewCommandLine
                Invoke lstrcat, Addr szLogMsg, Addr szCRLF
                Invoke GuiAddLogMessage, Addr szLogMsg
            .ENDIF            
            ;Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
            ;Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineManualChange
            ;Invoke lstrcat, Addr szLogMsg, Addr szNewCommandLine
            ;Invoke lstrcat, Addr szLogMsg, Addr szCRLF
            ;Invoke GuiAddLogMessage, Addr szLogMsg
            
            ; do the call to setcmdline
            Invoke lstrcat, Addr szNewCommandLine, Addr szCRLF
            _DbgFunctions SetCmdline, Addr szNewCommandLine
            
            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
        
        .ELSEIF eax == IDC_BtnAddCmdLineCancel
            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
        
        .ENDIF
    .ELSE
        mov eax, FALSE
        ret
	.ENDIF
    mov eax, TRUE
    ret
AddCmdLineDlgProc endp


;=====================================================================================
; AutoCmdLineCreateHash - Hash a string
;-------------------------------------------------------------------------------------
AutoCmdLineCreateHash PROC PUBLIC USES EBX StringToHash:DWORD, HashedString:DWORD
    LOCAL hProv:HCRYPTPROV
    LOCAL hHash:HCRYPTHASH
    LOCAL pbHash:DWORD
    LOCAL dwHashLen:DWORD
    LOCAL dwCount:DWORD
    LOCAL lenStringToHash:DWORD
    LOCAL pTempHashString:DWORD
    LOCAL pcchString:DWORD
    
    Invoke lstrlen, StringToHash
    mov lenStringToHash, eax

    
    Invoke CryptAcquireContext, Addr hProv, NULL, NULL, PROV_RSA_FULL, 0; CRYPT_SILENT
    .IF eax != FALSE
        Invoke CryptCreateHash, hProv, CALG_MD5, 0, 0, Addr hHash
        .IF eax != FALSE
            Invoke CryptHashData, hHash, StringToHash, lenStringToHash, 0
            .IF eax != FALSE
                mov dwCount, 4d
                Invoke CryptGetHashParam, hHash, HP_HASHSIZE, Addr dwHashLen, Addr dwCount, 0
                .IF eax != FALSE
                    Invoke GlobalAlloc, GMEM_FIXED+GMEM_ZEROINIT, dwHashLen
                    .IF eax != NULL
                        mov pTempHashString, eax
                        
                        Invoke CryptGetHashParam, hHash, HP_HASHVAL, pTempHashString, Addr dwHashLen, 0
                        .IF eax != FALSE
                            
                            Invoke CryptBinaryToString, pTempHashString, dwHashLen, CRYPT_STRING_HEXRAW + CRYPT_STRING_NOCRLF, HashedString, Addr pcchString
                            
                            ;Invoke MessageBox, hwndDlg, StringToHash, pTempHashString, MB_OK
                            ;Invoke lstrcpyn, HashedString, pTempHashString, dwHashLen
                            
                            .IF dwHashLen == 0
                            ;    Invoke GuiAddLogMessage, Addr szZeroLengthHash
                            .ENDIF
                            
                            ;Invoke lstrcpy, Addr szLogMsg, Addr szCreateHashSuccess
                            ;Invoke lstrcat, Addr szLogMsg, HashedString
                            ;Invoke lstrcat, Addr szLogMsg, Addr szCRLF 
                            ;Invoke GuiAddLogMessage, Addr szLogMsg
                            
                            
                            Invoke GlobalFree, pTempHashString
                            Invoke CryptDestroyHash, hHash
                            Invoke CryptReleaseContext, hProv, 0
                            
                            mov eax, TRUE
                            ret
                        .ELSE
                            ;Invoke GuiAddLogMessage, Addr szErrorCryptGetHashParamVal
                        .ENDIF
                    .ELSE
                        ;Invoke GuiAddLogMessage, Addr szErrorGlobalAlloc
                    .ENDIF
                .ELSE
                    ;Invoke GuiAddLogMessage, Addr szErrorCryptGetHashParamSize
                .ENDIF
            .ELSE
                ;Invoke GuiAddLogMessage, Addr szErrorCryptHashData
            .ENDIF
        .ELSE
            ;Invoke GuiAddLogMessage, Addr szErrorCryptCreateHash
        .ENDIF
    .ELSE
        ;Invoke GuiAddLogMessage, Addr szErrorCryptAcquireContext
    .ENDIF
    mov eax, FALSE
    ret

AutoCmdLineCreateHash endp


;=====================================================================================
; AutoCmdLineLoadMenuIcon - Loads RT_RCDATA png resource and assigns it to ICONDATA
; Returns TRUE in eax if succesful or FALSE otherwise.
;-------------------------------------------------------------------------------------
AutoCmdLineLoadMenuIcon PROC USES EBX dwImageResourceID:DWORD, lpIconData:DWORD
    LOCAL hRes:DWORD
    
    ; Load image for our menu item
    Invoke FindResource, hInstance, dwImageResourceID, RT_RCDATA ; load png image as raw data
    .IF eax != NULL
        mov hRes, eax
        Invoke SizeofResource, hInstance, hRes
        .IF eax != 0
            mov ebx, lpIconData
            mov [ebx].ICONDATA.size_, eax
            Invoke LoadResource, hInstance, hRes
            .IF eax != NULL
                Invoke LockResource, eax
                .IF eax != NULL
                    mov ebx, lpIconData
                    mov [ebx].ICONDATA.data, eax
                    mov eax, TRUE
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov eax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov eax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov eax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov eax, FALSE
    .ENDIF    
    ret

AutoCmdLineLoadMenuIcon ENDP


END DllEntry
















