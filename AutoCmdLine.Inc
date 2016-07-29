;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2016 - www.LetTheLight.in
;
; AutoCmdLine.inc
;
;-------------------------------------------------------------------------------------
include windows.inc
include user32.inc
include kernel32.inc
include crypt32.inc
includelib user32.lib
includelib kernel32.lib
includelib crypt32.lib

;include MD5.inc
;includelib MD5.lib

AddCmdLineDlgProc               PROTO :DWORD, :DWORD, :DWORD, :DWORD
AutoCmdLineCreateHash           PROTO :DWORD, :DWORD
AutoCmdLineLoadMenuIcon         PROTO :DWORD, :DWORD

.CONST
CRLF                            TEXTEQU <13,10,0> ; carriage return and linefeed for strings that require them (GuiAddLogMessage for example) 

CRYPT_STRING_NOCRLF             EQU 40000000h
CRYPT_STRING_HEXRAW             EQU 0000000ch
ALG_CLASS_HASH                  equ 32768

ICO_AUTOCMDLINE                 EQU 100
IMG_AUTOCMDLINE                 EQU 101 ; PNG image for plugin menu icon

MENU_PLUGIN1                    EQU 31
;IDD_AutoCmdLine                 EQU 3000
;IDC_PLUGINDLG_OK                EQU 3001


;AddChangeCmdLine.dlg
IDD_AddCmdLine					equ 2000
IDC_LblAddCmdLineModuleFilename	equ 2001
IDC_LblAddCmdLineCommandLine	equ 2003
IDC_TxtAddCmdLineCommandLine	equ 2004
IDC_TxtAddCmdLineModuleFilename	equ 2002
IDC_BtnAddCmdLineOK				equ 2005
IDC_ChkAddCmdLineRemember		equ 2006
IDC_BtnAddCmdLineCancel			equ 2007
;NewCmdLineDetected.dlg
;IDD_NewCmdLine					equ 2000
;IDC_TxtNewCmdLineModuleFilename	equ 2001
;IDC_LblNewCmdLineModuleFilename	equ 2002
;IDC_LblNewCmdLineInfo1			equ 2003
;IDC_TxtNewCmdLineOldCmdLine		equ 2004
;IDC_LblNewCmdLineOldCmdLine		equ 2005
;IDC_LblNewCmdLineNewCmdLine		equ 2006
;IDC_TxtNewCmdLineNewCmdLine		equ 2007
;IDC_BtnNewCmdLineUseNew			equ 2008
;IDC_BtnNewCmdLineUseNewRemember	equ 2009
;IDC_BtnNewCmdLineUseOld			equ 2010
;IDC_LblNewCmdLineInfo2			equ 2011


.DATA
szMenuPlugin1                   DB "Add/Change CmdLine...",0

szAutoCmdLineInfo               DB 13,10         
                                DB "AutoCmdLine x32dbg plugin by fearless 2016 - www.LetTheLight.in",13,10
                                DB 13,10
                                DB "AutoCmdLine Features & Usage:",13,10
                                DB " - Adds a dialog (from plugin menu) where you can see and change command line",13,10  
                                DB " - Option to remember command line for next time the same module is loaded",13,10
                                DB " - Auto sets command line when loading a module - if it was set to remember it",13,10
                                DB 13,10,0

szPluginLoaded                  DB "AutoCmdLine loaded.",CRLF
szPluginUnloaded                DB "AutoCmdLine unloaded.",CRLF
szDebuggingRequired             DB "AutoCmdLine: You need to be debugging to use this option!",CRLF
szAutoCmdLineManualChange       DB "AutoCmdLine: Command line has been changed to: ",0
szAutoCmdLineAutoChange         DB "AutoCmdLine: Command line has been automatically changed to: ",0
szAutoCmdLineRemember           DB "AutoCmdLine: Command line will be remembered: ",0
szAutoCmdLineForgotten          DB "AutoCmdLine: Command line wont be remembered (its forgotten already): ",0
szLogMsg                        DB 1024 DUP (0)

szErrorCryptHashData            DB "AutoCmdLine Error: HashData",CRLF
szErrorCryptCreateHash          DB "AutoCmdLine Error: CryptCreateHash",CRLF
szErrorCryptAcquireContext      DB "AutoCmdLine Error: CryptAcquireContext",CRLF
szErrorCryptGetHashParamSize    DB "AutoCmdLine Error: CryptGetHashParam::Size",CRLF
szErrorCryptGetHashParamVal     DB "AutoCmdLine Error: CryptGetHashParam::Value",CRLF
szCreateHashSuccess             DB "AutoCmdLine Error: CreateHash Success: ",0
szZeroLengthHash                DB "Zero Length Hash",CRLF
szErrorGlobalAlloc              DB "AutoCmdLine Error: GlobalAlloc",CRLF
szIniGetModuleCmdLine           DB "IniGetModuleCmdLine: ",0
szIniSetModuleCmdLine           DB "IniSetModuleCmdLine: ",0
szCBINITDEBUG                   DB "AutoCmdLine (MD5): ",0

szIni                           DB "ini",0
AutoCmdLineIni                  DB MAX_PATH DUP (0)
szModuleFilename                DB MAX_PATH DUP (0)
szCommandLine                   DB 1024 DUP (0)
szNewCommandLine                DB 1024 DUP (0)
dwCmdLineSize                   DD 0
dwRemember                      DD 0

DebugFilename                   DD 0
DebugFilenameMD5                DB 256 DUP (0)


szIniCmdLine                    DB "CmdLine",0
szIniRemember                   DB "Remember",0           
szCRLF                          DB 13,10,0
szColon                         DB ":",0
szQuote                         DB 22h,0
szZero                          DB "0",0
szOne                           DB "1",0
szQ                             DB "?",0
szSpace                         DB " ",0
sel                             SELECTIONDATA <>

.DATA?
hInstance                       DD ?
hIcoAutoCmdLine                 DD ?
