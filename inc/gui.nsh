!include "Sections.nsh"
!include "x64.nsh"
!include "inc\winver_string.nsh"
!include "inc\datetime.nsh"

Var BGPositionX
Var BGPositionY
Var BGExitPositionX
Var BGExitPositionY
  
Var SecProtocolState
  
Function .onInit
  ; open a debug file if necessary
  !ifdef DEBUG
    FileOpen $LogFile "$TEMP\nsislog.txt" "a"
	FileSeek $LogFile 0 END 
  !endif
  
  ${RuntimeTime} $R0
  ${LogWrite} "========== $EXEFILE Started - $R0 =========="
  ${LogWrite} "${PRODUCT_NAME} Version ${PRODUCT_VERSION}"
  ${LogWrite} "For answers to your questions or if you need any additional support please visit: ${PRODUCT_WEB_SITE}"
  ${LogWrite} "----------------"
  ; initialize the runtime plugins directory
  InitPluginsDir
  ${LogWrite} "Runtime Plugins Directory: $PLUGINSDIR"
  
  ; set the default install directory
  StrLen $R0 $WINDIR
  StrCpy $R0 $WINDIR 1 -$R0
  StrCpy $INSTDIR "$R0:\Dynamix\Starsiege"
  ${LogWrite} "Default Install Directory: $INSTDIR"
  
  ${WinVer_GetVersionString} $R0
  ${LogWrite} "OS Detected: $R0"
  
  ; set the default registry locations
  ${If} ${AtLeastWin7}
	StrCpy "$PRODUCT_PATH_HIVE" "HKCU"
  	StrCpy "$PRODUCT_UNINST_HIVE" "HKCU"
  ${Else}
    StrCpy "$PRODUCT_PATH_HIVE" "HKLM"
    StrCpy "$PRODUCT_UNINST_HIVE" "HKLM"
  ${EndIf}
  ${If} ${RunningX64}
    SetRegView 64
    StrCpy "$PRODUCT_PATH_KEY" "Software\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_FILENAME}"
    StrCpy "$PRODUCT_UNINST_KEY" "Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
  ${Else}
    SetRegView 32
    StrCpy "$PRODUCT_PATH_KEY" "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_FILENAME}"
    StrCpy "$PRODUCT_UNINST_KEY" "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
  ${EndIf}
  
  ${LogWrite} "App Path Key: $PRODUCT_PATH_HIVE\$PRODUCT_PATH_KEY"
  ${LogWrite} "Add/Remove Programs Key: $PRODUCT_UNINST_HIVE\$PRODUCT_UNINST_KEY"

  ; get the X and Y size of the current screen
  System::Call 'user32::GetSystemMetrics(i 0) i .r0'
  System::Call 'user32::GetSystemMetrics(i 1) i .r1'
  ${LogWrite} "Detected Screen Resolution: $0x$1"
  
  ; center the installer's background
  IntOp $BGPositionX $0 - 1024
  IntOp $BGPositionX $BGPositionX / 2
  IntOp $BGPositionY $1 - 768
  IntOp $BGPositionY $BGPositionY / 2
  ${LogWrite} "Installer Background Offset: $BGPositionXx$BGPositionY"
  
  ; center the exit splash background
  IntOp $BGExitPositionX $0 - 1141
  IntOp $BGExitPositionX $BGExitPositionX / 2
  IntOp $BGExitPositionY $1 - 830
  IntOp $BGExitPositionY $BGExitPositionY / 2
  ${LogWrite} "End Splash Screen Offset: $BGExitPositionXx$BGExitPositionY"

  ; display our splash screen
  File /oname=$PLUGINSDIR\splash.bmp res\splash.bmp
  advsplash::show 1000 600 400 -1 $PluginsDir\splash

  Pop $0 ; $0 has '1' if the user closed the splash screen early,
         ; '0' if everything closed normally, and '-1' if some error occurred.
FunctionEnd

Function onGUIInit
  ; .onGUIInit is used by MUI2 so we use a callback here
  ; extract our background image
  File /oname=$PLUGINSDIR\bg.bmp "res\bg.bmp"

  # turn return values on if in debug mode
  !ifdef DEBUG
	BgImage::SetReturn on
  !endif

  # set the initial background for images to be drawn on
  # we will use a gradient from drak green to dark red
  BgImage::SetBg /GRADIENT 0 0 0 0 0 0
  BgImage::AddImage $PLUGINSDIR\bg.bmp $BGPositionX $BGPositionY

  # show our creation to the world!
  BgImage::Redraw
  # Refresh doesn't return any value
  
  ; save initial selected sections
  StrCpy "$SecProtocolState" ${SecProtocol_None}
  
FunctionEnd

Function .onSelChange
  ; Get SecProtocol Section flags 
  SectionGetFlags ${SecProtocol} $R0
  IntOp $R0 $R0 & ${SF_SELECTED} ; mask out everything except the fully selected flag

  ; reset the SecProtocol category if it's fully selected (invalid state)
  ${If} $R0 == ${SF_SELECTED}
    !insertmacro SelectSection ${SecProtocol_None}
    !insertmacro UnSelectSection ${SecProtocol_v3}
    !insertmacro UnSelectSection ${SecProtocol_v4}
  ${EndIf}

  ; perform default RadioButton handler
  !insertmacro StartRadioButtons "$SecProtocolState"
    !insertmacro RadioButton ${SecProtocol_None}
    !insertmacro RadioButton ${SecProtocol_v3}
    !insertmacro RadioButton ${SecProtocol_v4}
  !insertmacro EndRadioButtons

FunctionEnd

Function onAbort
  ${LogWrite} "********** Installation Aborted **********"
FunctionEnd

Function .onInstFailed
  ${LogWrite} "!!!!!!!!!! Installation Failed !!!!!!!!!!"
FunctionEnd

Function .onInstSuccess
  ${LogWrite} "========== Installation Success =========="
  Call OpenInstallDirectory
FunctionEnd

Function .onGUIEnd
  ; extract our background images
  File /oname=$PLUGINSDIR\bg-back.bmp "res\bg-back.bmp"
  File /oname=$PLUGINSDIR\bg-joinus.bmp "res\bg-joinus.bmp"

  ; clear the current background
  BgImage::Clear
  BgImage::SetBg /GRADIENT 0 0 0 0 0 0

  ; add the stary background first
  BgImage::AddImage $PLUGINSDIR\bg-back.bmp 0 0

  ; layer the transparent version of the joinus image
  BgImage::AddImage /TRANSPARENT 255 0 255 $PLUGINSDIR\bg-joinus.bmp $BGExitPositionX $BGExitPositionY

  ; display for 3 seconds
  BgImage::Redraw
  Sleep 3000

  ; clean up
  BgImage::Destroy
  
  ${LogWrite} "========== Installer Exit - $R0 =========="
  FileClose $LogFile
FunctionEnd

; Completion Functions
Function OpenDiscord
  ExecShell "open" "${PRODUCT_DISCORD_URL}"
FunctionEnd
Function OpenReleaseNotes
  ExecShell "open" "${PRODUCT_WEB_SITE}\download"
FunctionEnd
Function OpenInstallDirectory
  ExecShell "" "explorer.exe" "/select,$INSTDIR\${PRODUCT_FILENAME}"
FunctionEnd

; Individual Customization Functions
Function WelcomeShow
FunctionEnd

Function LicenseShow
  File /oname=$PLUGINSDIR\header1.bmp "res\header1.bmp"
  !insertmacro MUI_HEADERIMAGE_INITHELPER_LOADIMAGE "${MUI_PAGE_UNINSTALLER_PREFIX}" "" 1046 $PLUGINSDIR\header1.bmp
FunctionEnd

Function ComponentsShow
  File /oname=$PLUGINSDIR\header2.bmp "res\header2.bmp"
  !insertmacro MUI_HEADERIMAGE_INITHELPER_LOADIMAGE "${MUI_PAGE_UNINSTALLER_PREFIX}" "" 1046 $PLUGINSDIR\header2.bmp
FunctionEnd

Function DirectoryShow
  File /oname=$PLUGINSDIR\header2.bmp "res\header2.bmp"
  !insertmacro MUI_HEADERIMAGE_INITHELPER_LOADIMAGE "${MUI_PAGE_UNINSTALLER_PREFIX}" "" 1046 $PLUGINSDIR\header2.bmp
FunctionEnd

Function InstallShow
  File /oname=$PLUGINSDIR\header3.bmp "res\header3.bmp"
  !insertmacro MUI_HEADERIMAGE_INITHELPER_LOADIMAGE "${MUI_PAGE_UNINSTALLER_PREFIX}" "" 1046 $PLUGINSDIR\header3.bmp
FunctionEnd

Function FinishShow
  File /oname=$PLUGINSDIR\panel3.bmp "res\panel3.bmp"
  !insertmacro MUI_INTERNAL_FULLWINDOW_LOADWIZARDIMAGE "${MUI_PAGE_UNINSTALLER_PREFIX}" $mui.FinishPage.Image $PLUGINSDIR\panel3.bmp $mui.FinishPage.Image.Bitmap
FunctionEnd