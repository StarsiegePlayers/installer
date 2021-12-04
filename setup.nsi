;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Starsiege Players Distribution Installer
; https://starsiegeplayers.com/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!AddPluginDir /amd64-unicode "plugins\x64-unicode"
!AddPluginDir /x86-unicode   "plugins\x86-unicode"
!AddPluginDir /x86-ansi      "plugins\x86-ansi"

!include "inc\datetime.nsh"

!define REVISION "0"
!define VERSION "${VERSIONDATE}"
!define PRODUCT_NAME "Starsiege ${VERSION}"
!define PRODUCT_VERSION "${PRODUCTDATE}.${REVISION}"
!define PRODUCT_GROUP "Starsiege"
!define PRODUCT_PUBLISHER "Starsiege Players"
!define PRODUCT_FILENAME "Starsiege.exe"
!define PRODUCT_WEB_SITE "https://starsiegeplayers.com/"
!define PRODUCT_DISCORD_URL "https://discord.gg/KA4N6J8"
!define PRODUCT_DIR_REGHIVE "HKCU"
!define PRODUCT_DIR_REGKEY "Software\Dynamix\Starsiege"
!define PRODUCT_PROTOCOL_REGKEY_MAIN "starsiege"
!define PRODUCT_PROTOCOL_REGKEY_OPEN "starsiege\shell\open\command"
!define PRODUCT_ID "{4305FA8F-4A2A-4BCF-BFD9-21BCCFAD6F3D}"

Var /GLOBAL PRODUCT_UNINST_KEY
Var /GLOBAL PRODUCT_UNINST_HIVE
Var /GLOBAL PRODUCT_PATH_KEY
Var /GLOBAL PRODUCT_PATH_HIVE

Var /GLOBAL ProtocolInstalled

;--------------------------------
; Initial Setup
  Unicode true
  ManifestDPIAware true

  Var /GLOBAL LogFile
  ;!define DEBUG
  !define VERBOSE
  !verbose 3

  !include "inc\debug.nsh"
  
  ;!define NSIS_7z_COMPRESSION

  !ifdef NSIS_LZMA_COMPRESSION
    !ifndef NSIS_LZMA_COMPRESS_WHOLE
      SetCompressor lzma
    !else
      SetCompressor /SOLID lzma
    !endif
  !endif

;--------------------------------
;General

  ; Name and file
  Name "${PRODUCT_GROUP}"
  OutFile "starsiegesetup.exe"

  !include "inc\version.nsh"

  SetOverwrite ifdiff
  CRCCheck on
  BrandingText "${PRODUCT_PUBLISHER} | ${VERSION}"
  ShowInstDetails show

  ;Get installation folder from registry if available
  InstallDirRegKey ${PRODUCT_DIR_REGHIVE} ${PRODUCT_DIR_REGKEY} "InstallDIR"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user
  ManifestSupportedOS all

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include "LogicLib.nsh"
  !include "x64.nsh"
  
;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_ABORTWARNING_CANCEL_DEFAULT
  
  !define MUI_UNABORTWARNING
  !define MUI_UNABORTWARNING_CANCEL_DEFAULT
  
  !define MUI_ICON "res\icon.ico"
  !define MUI_UNICON "res\uninstall.ico"

  !define MUI_CUSTOMFUNCTION_GUIINIT onGUIInit
  !define MUI_CUSTOMFUNCTION_ABORT onAbort
  
  ; Banner (welcome and finish page) for installer
  !define MUI_WELCOMEFINISHPAGE_BITMAP "res\panel1.bmp"
  ; Banner for uninstaller
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP "res\panel1.bmp"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "res\header1.bmp"

  !define MUI_COMPONENTSPAGE_SMALLDESC
  
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_TEXT "&Open the Starsiege Discord"
  !define MUI_FINISHPAGE_RUN_FUNCTION OpenDiscord
  
  !define MUI_FINISHPAGE_SHOWREADME 
  !define MUI_FINISHPAGE_SHOWREADME_TEXT "View the &Release Notes"
  !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION OpenReleaseNotes
  
  !define MUI_FINISHPAGE_LINK "Visit us at ${PRODUCT_WEB_SITE} for the latest news, FAQs and support"
  !define MUI_FINISHPAGE_LINK_LOCATION ${PRODUCT_WEB_SITE}
  

;--------------------------------
;Pages

  !define MUI_PAGE_CUSTOMFUNCTION_SHOW WelcomeShow
  !insertmacro MUI_PAGE_WELCOME

  !define MUI_PAGE_CUSTOMFUNCTION_SHOW LicenseShow
  !insertmacro MUI_PAGE_LICENSE "License"

  !define MUI_PAGE_CUSTOMFUNCTION_SHOW ComponentsShow
  !insertmacro MUI_PAGE_COMPONENTS

  !define MUI_PAGE_CUSTOMFUNCTION_SHOW DirectoryShow
  !insertmacro MUI_PAGE_DIRECTORY
  
  !define MUI_PAGE_CUSTOMFUNCTION_SHOW InstallShow
  !insertmacro MUI_PAGE_INSTFILES

  !define MUI_PAGE_CUSTOMFUNCTION_SHOW FinishShow
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section -Prerequisites

  ; proposed manifest url
  ; https://install.starsiegeplayers.com/base.json or xml

  ${LogWrite} "Downloading Visual C++ 2019 Redistributable Package..."
  
  ${If} ${RunningX64}
    StrCpy $0 "vc_redist.x64.exe"
  ${Else}
    StrCpy $0 "vc_redist.x86.exe"
  ${EndIf}
  
  ${LogWrite} "Fetching: $0"
  
  NScurl::http get "https://aka.ms/vs/16/release/$0" "$PLUGINSDIR\$0" /CANCEL /RESUME /RETURN "@ERRORCODE@ - @ELAPSEDTIME@" /END
  Pop $1
  ${LogWrite} $1
  
  ${LogWrite} "$0 /install /quiet /norestart"
  ExecWait '"$PLUGINSDIR\$0" /install /quiet /norestart' $1
  DetailPrint "Returned $1"
  
SectionEnd

; if an existing install was detected, provide the option to update
; proposed url
; https://install.starsiegeplayers.com/update.7z

Section "Base Installation" SecBase
  ; proposed url
  ; https://install.starsiegeplayers.com/base.7z

  SetOutPath "$INSTDIR"
  !ifndef DEBUG
    !ifdef NSIS_7z_COMPRESSION
	  ${CEcho} "Adding file ..\base.7z"
	  SetCompress off
	  File "..\base.7z"
	  Nsis7z::Extract "$PLUGINSDIR\base.7z"
	  SetCompress auto
	!else
	  File /r /x .git ..\ss-rerelease\*
	!endif
  !endif

SectionEnd

Section "Client Extras" SecExtras
  ; proposed url
  ; https://install.starsiegeplayers.com/extras.7z
  
  SetOutPath "$INSTDIR"
  !ifndef DEBUG
	!ifdef NSIS_7z_COMPRESSION
	  ${CEcho} "Adding file ..\extras.7z"
	  SetCompress off
	  File "..\extras.7z"
	  Nsis7z::Extract "$PLUGINSDIR\extras.7z"
	  SetCompress auto
	!else
	  File /r /x .git ..\ss-rerelease-extras\*
	!endif
  !endif

SectionEnd

Section /o "Dedicated Server Scripts" SecServer
  ; proposed url
  ; https://install.starsiegeplayers.com/server.7z

  SetOutPath "$INSTDIR\dedicated-server"
  !ifndef DEBUG
    !ifdef NSIS_7z_COMPRESSION
	  ${CEcho} "Adding file ..\server.7z"
	  SetCompress off
	  File "..\server.7z"
	  Nsis7z::Extract "$PLUGINSDIR\server.7z"
	  SetCompress auto
	!else
	  File /r /x .git ..\ss-rerelease-server\*
	!endif
  !endif
  
SectionEnd

SectionGroup /e "Handle starsiege:// URLs" SecProtocol

	Section /o "v1.003" SecProtocol_v3
	  !ifndef DEBUG
	    StrCpy $R0 ${PRODUCT_FILENAME}
		Call SetStarsiegeProtocolHandler
	  !endif
	SectionEnd
	
	Section /o "v1.004" SecProtocol_v4
	  !ifndef DEBUG
	    StrCpy $R0 "Starsiege_1004.exe"
	    Call SetStarsiegeProtocolHandler
      !endif
	SectionEnd
	
	Section "None" SecProtocol_None
	SectionEnd
	
SectionGroupEnd

Function SetStarsiegeProtocolHandler
  ; https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/aa767914(v=vs.85)
  DetailPrint "Setting $R0 as the default Starsiege executable"
  WriteRegStr HKCR ${PRODUCT_PROTOCOL_REGKEY_MAIN} "" "URL:Starsiege Protocol"
  WriteRegStr HKCR ${PRODUCT_PROTOCOL_REGKEY_MAIN} "URL Protocol" ""
  WriteRegStr HKCR ${PRODUCT_PROTOCOL_REGKEY_MAIN} "DefaultIcon" "$INSTDIR\$R0,1"
  WriteRegStr HKCR ${PRODUCT_PROTOCOL_REGKEY_MAIN} "Executable" "$INSTDIR\$R0"
  WriteRegStr HKCR ${PRODUCT_PROTOCOL_REGKEY_OPEN} "" '"$INSTDIR\launch.exe" "%1"'
  
  ${If} $R0 == ${PRODUCT_FILENAME}
    WriteRegStr HKCR "Applications\$R0\shell\open" "FriendlyAppName" "Starsiege v1.004"
  ${Else}
    WriteRegStr HKCR "Applications\$R0\shell\open" "FriendlyAppName" "Starsiege v1.003"
  ${EndIf}
  WriteRegStr HKCR "Applications\$R0\DefaultIcon" "" '$INSTDIR\$R0,1'
  WriteRegStr HKCR "Applications\$R0\shell\command" "" '"$INSTDIR\launch.exe" "%1"'
  
  
  StrCpy ${ProtocolInstalled} "1"
FunctionEnd

Section -Post
  !ifndef DEBUG
	${LogWrite} "Populating registry entries"
    ;Store installation folder
    WriteRegStr ${PRODUCT_DIR_REGHIVE} ${PRODUCT_DIR_REGKEY} "InstallDIR" $INSTDIR
	
	; Register starsiege.exe
	WriteRegStr ${PRODUCT_PATH_HIVE} ${PRODUCT_PATH_KEY} "" '"$INSTDIR\${PRODUCT_FILENAME}"'
	WriteRegStr ${PRODUCT_PATH_HIVE} ${PRODUCT_PATH_KEY} "Path" '"$INSTDIR"'
	
	; Register Starsiege_1004.exe
	WriteRegStr ${PRODUCT_PATH_HIVE} ${PRODUCT_PATH_KEY} "" '"$INSTDIR\Starsiege_1004.exe"'
	WriteRegStr ${PRODUCT_PATH_HIVE} ${PRODUCT_PATH_KEY} "Path" '"$INSTDIR"'
	
	; Add additional information if the protocol handler was installed
	${If} ${ProtocolInstalled} == "1"
	  WriteRegStr ${PRODUCT_PATH_HIVE} ${PRODUCT_PATH_KEY} "SupportedProtocols" "starsiege"
	  WriteRegDWORD ${PRODUCT_PATH_HIVE} ${PRODUCT_PATH_KEY} "UseUrl" 0x1
	${EndIf}
	
	
	${LogWrite} "Writing uninstall information"
	
	; add/remove programs doesn't use date seperators - yyyymmdd
	!insertmacro RuntimeAddRemoveDate $0
	
	WriteRegDWORD ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "EstimatedSize" 0xB7C00 ; 532 Mib
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "DisplayIcon" '"$INSTDIR\${PRODUCT_FILENAME}"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "DisplayName" '"${PRODUCT_NAME}"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "DisplayVersion" '"${PRODUCT_VERSION}"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "Version" '"${PRODUCT_VERSION}"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "InstallDate" '"$0"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "InstallLocation" '"$INSTDIR"'
	WriteRegDWORD ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "NoModify" 0x1
	WriteRegDWORD ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "NoRepair" 0x1
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "Publisher" '"$PRODUCT_PUBLISHER"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "UninstallString" '"$INSTDIR\Uninstall.exe"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "URLInfoAbout" '"${PRODUCT_WEB_SITE}"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "URLUpdateInfo" '"${PRODUCT_WEB_SITE}"'
	WriteRegStr ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY} "HelpLink" '"${PRODUCT_DISCORD_URL}"'	
	
    ;Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
  !endif
SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecBase ${LANG_ENGLISH} "Installs this release of ${PRODUCT_GROUP} built on " ; string finishes with <product_version>
  LangString DESC_SecExtras ${LANG_ENGLISH} "Installs community designed skins, preserved doumentation, and original tools"
  LangString DESC_SecServer ${LANG_ENGLISH} "A default dedicated server installation, includes scripts and doumentation"
  LangString DESC_SecProtocol ${LANG_ENGLISH} "Clicking on a starsiege:// URL will open your choice of Starsiege client"
  LangString DESC_SecProtocol_v3 ${LANG_ENGLISH} "Sets v1.003 as your default Starsiege client"
  LangString DESC_SecProtocol_v4 ${LANG_ENGLISH} "Sets v1.004 as your default Starsiege client"
  LangString DESC_SecProtocol_None ${LANG_ENGLISH} "Does not set a client for starsiege:// URLs"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecBase} $(DESC_SecBase)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecExtras} $(DESC_SecExtras)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecServer} $(DESC_SecServer)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecProtocol} $(DESC_SecProtocol)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecProtocol_v3} $(DESC_SecProtocol_v3)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecProtocol_v4} $(DESC_SecProtocol_v4)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecProtocol_None} $(DESC_SecProtocol_None)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...

  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_DIR_REGHIVE} ${PRODUCT_DIR_REGKEY}
  DeleteRegKey ${PRODUCT_PATH_HIVE}   ${PRODUCT_PATH_KEY}
  DeleteRegKey ${PRODUCT_UNINST_HIVE} ${PRODUCT_UNINST_KEY}

SectionEnd

;--------------------------------
;GUI Customizations
  !include "inc\gui.nsh"
