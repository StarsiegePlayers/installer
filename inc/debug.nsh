!include "inc\datetime.nsh"

; https://nsis.sourceforge.io/Verbose_Print_Macro
; -----------------------------
;       VerbosePrint.nsh
; -----------------------------
;
; Very simple macro to "DetailPrint" if "VERBOSE" is defined.
;
; Useage:
/*
    !define VERBOSE
 
    !include VerbosePrint.nsh
 
    OutFile VerboseTest.exe
    ShowInstDetails show
 
    Section -Test
        ${VerbosePrint} 'This message will only print if VERBOSE is defined.'
    SectionEnd
*/
 
 
!ifndef VerbosePrint
    !define VerbosePrint "!insertmacro VerbosePrint"
    !ifmacrondef VerbosePrint
        !macro VerbosePrint MESSAGE
            !ifdef VERBOSE
                   DetailPrint `${MESSAGE}`
            !endif
        !macroend
    !endif
!endif ; VerbosePrint

;--------------------------------
; Logging Debug

!ifndef LogWrite
  Var /Global __LogTime
  !define LogWrite "!insertmacro _LogWrite"
  !ifmacrondef _LogWrite
    !macro _LogWrite text
      ${VerbosePrint} "${text}"
      !ifdef DEBUG
	    ${RuntimeTime} "$__LogTime"
        FileWrite $LogFile '[$__LogTime] ${text}$\r$\n'
      !endif
    !macroend
  !endif
!endif ; LogWrite


!ifndef CEcho
  !define CEcho "!insertmacro _CEcho"
  !ifmacrondef _CEcho
    !macro _CEcho text
	  !verbose push
	  !verbose 4
	  !echo "${text}"
	  !verbose pop
    !macroend
  !endif
!endif