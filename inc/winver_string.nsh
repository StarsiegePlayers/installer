!ifndef __WINVER_STRING_NSH__
!define __WINVER_STRING_NSH__

  !include "LogicLib.nsh"
  !include "WinVer.nsh"
  
  !ifndef WinVer_GetVersionString
    !define WinVer_GetVersionString "!insertmacro WinVer_GetVersionString"
    !macro WinVer_GetVersionString output
      StrCpy "${output}" "Windows"
	
      ${If} ${IsNT}
	    ${If} ${IsWinNT4}
	      StrCpy "${output}" "${output} NT 4"
	    ${ElseIf} ${IsWin2000}
	      StrCpy "${output}" "${output} 2000"
	    ${ElseIf} ${IsWinXP}
	      StrCpy "${output}" "${output} XP"
	    ${ElseIf} ${IsWin2003}
	      StrCpy "${output}" "${output} 2003"
	    ${ElseIf} ${IsWinVista}
	      StrCpy "${output}" "${output} Vista"
	    ${ElseIf} ${IsWin2008}
	      StrCpy "${output}" "${output} 2008"
	    ${ElseIf} ${IsWin7}
	      StrCpy "${output}" "${output} 7"
	    ${ElseIf} ${IsWin2008R2}
	      StrCpy "${output}" "${output} 2008R2"
	    ${ElseIf} ${IsWin8}
	      StrCpy "${output}" "${output} 8"
	    ${ElseIf} ${IsWin2012}
	      StrCpy "${output}" "${output} 2012"
	    ${ElseIf} ${IsWin8.1}
	      StrCpy "${output}" "${output} 8.1"
	    ${ElseIf} ${IsWin2012R2}
	      StrCpy "${output}" "${output} 2012R2"
	    ${ElseIf} ${IsWin10}
	      StrCpy "${output}" "${output} 10"
	    ${ElseIf} ${IsWin2016}
	      StrCpy "${output}" "${output} 2016"
        ${Else}
	      StrCpy "${output}" "${output} Unknown"
	     ${EndIf}
	  ${Else}
	    ${If} ${IsWin95}
	      StrCpy "${output}" "${output} 95"
	    ${ElseIf} ${IsWin98}
	      StrCpy "${output}" "${output} 98"
	    ${ElseIf} ${IsWinME}
	      StrCpy "${output}" "${output} ME"
	    ${Else}
	      StrCpy "${output}" "${output} Unknown"
	    ${EndIf}
	  ${EndIf}
	  ${If} ${IsServerOS}
	    StrCpy "${output}" "${output} Server"
	  ${EndIf}
	  ${If} ${IsStarterEdition}
	    StrCpy "${output}" "${output} Starter"
	  ${EndIf}
	  ${If} ${OSHasTabletSupport}
	    StrCpy "${output}" "${output} Tablet"
	  ${EndIf}
	
	  ${WinVerGetMajor} $0
	  StrCpy "${output}" "${output} ($0"
	
	  ${WinVerGetMinor} $0
	  StrCpy "${output}" "${output}.$0"
	
	  ${WinVerGetBuild} $0
	  StrCpy "${output}" "${output}.$0)"
    !macroend
  !endif

!endif