!include "FileFunc.nsh"

; Compile DateTime
!ifndef VERSIONDATE
  !define /date VERSIONDATE "%Y-%m-%d"
!endif
!ifndef PRODUCTDATE
  !define /date PRODUCTDATE "%Y.%m.%d"
!endif

!ifndef __DT_TEMP
  !define __DT_TEMP "!insertmacro __DT_TEMP"
  !ifmacrondef __DT_TEMP
  !macro __DT_TEMP
      Var /GLOBAL __D0
      Var /GLOBAL __D1
      Var /GLOBAL __D2
      Var /GLOBAL __D3
      Var /GLOBAL __D4
      Var /GLOBAL __D5
      Var /GLOBAL __D6
	  Var /GLOBAL __D7
	  Var /GLOBAL __D8
	  Var /GLOBAL __D9
    !macroend
  !endif
!endif

!ifndef RuntimeDate
  !define RuntimeDate "!insertmacro RuntimeDate"
  !ifmacrondef RuntimeDate
    !macro RuntimeDate output
	  ${__DT_TEMP}
	  ${GetTime} "" "L" $__D0 $__D1 $__D2 $__D3 $__D4 $__D5 $__D6
	  StrCpy ${output} '$__D2/$__D1/$__D0'
	!macroend
  !endif
!endif

!ifndef RuntimeAddRemoveDate
  !define RuntimeAddRemoveDate "!insertmacro RuntimeAddRemoveDate"
  !ifmacrondef RuntimeAddRemoveDate
    !macro RuntimeAddRemoveDate output
	  ${__DT_TEMP}
	  ${GetTime} "" "L" $__D0 $__D1 $__D2 $__D3 $__D4 $__D5 $__D6
	  StrCpy ${output} '$__D0$__D2$__D1'
	!macroend
  !endif
!endif

!ifndef RuntimeTime
  !define RuntimeTime "!insertmacro RuntimeTime"
  !ifmacrondef RuntimeTime
    !macro RuntimeTime output
	  ${__DT_TEMP}
	  ${GetTime} "" "L" $__D0 $__D1 $__D2 $__D3 $__D4 $__D5 $__D6
	  StrCpy ${output} '$__D4:$__D5:$__D6'
	!macroend
  !endif
!endif

!ifndef RuntimeDatetime
  !define RuntimeDatetime "!insertmacro RuntimeDatetime"
  !ifmacrondef RuntimeDatetime
    !macro RuntimeDatetime output
	  ${__DT_TEMP}
	  ${RuntimeDate} $__D8
	  ${RuntimeTime} $__D9
	  StrCpy ${output} "$__D8 $__D9"
	!macroend
  !endif
!endif