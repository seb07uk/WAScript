@echo off &title Nested GUI buttons example via mshta snippet by AveYo                &rem preview: https://i.imgur.com/bAIuIHy.png
:: v2: less flicker

:gui_dialog_1
set first_choices=Option 1,Option 2,Option3,Option4,Finish&set title=Simple GUI choices #1
:: Show gui dialog 1=Title 2=choices 3=outputvariable
call :choice "Simple GUI buttons" "%first_choices%" CHOICE
:: Quit if no choice selected
if not defined CHOICE color 0c &echo  ERROR! No choice selected.. &timeout /t 20 &color 07 &exit/b
:: Print choices
echo Choice1: %CHOICE% & echo.
:: Continue to dialog_2
goto gui_dialog_2

:gui_dialog_2
:: Process results from dialog_1
if "%CHOICE%"=="Option 1" set next_choices=Suboption 1 1,Suboption 1 2,Suboption 1 3,Back&set title=Option 1
if "%CHOICE%"=="Option 2" set next_choices=Suboption 2 1,Suboption 2 2,Back&set title=Option 2
if "%CHOICE%"=="Option3"  set next_choices=Suboption 3 1,Suboption 3 2,Suboption 3 3,Suboption 3 4,Back&set title=Option3
if "%CHOICE%"=="Option4"  call :"Option4" &goto Done no suboption
if "%CHOICE%"=="Finish"   call :"Finish"  &goto Done no suboption
:: Show gui dialog 1=Title 2=choices 3=outputvariable
call :choice "%title%" "%next_choices%" CHOICE
:: Quit if no choice selected
if not defined CHOICE color 0c &echo  ERROR! No choice selected.. &timeout /t 20 &color 07 &exit/b
:: Print choices
echo Choice2: %CHOICE% & echo.
:: Back to dialog_1
if "%CHOICE%"=="Back" goto gui_dialog_1

:: Process final choice
call :"%CHOICE%"

:Done
timeout /t -1
exit/b

:: Choice code
:"Option4"
echo running code for %0
rem @ECHO OFF
::SET "_WAIT_SECONDS=%~1"
::IF "%~1"=="" SET "_WAIT_SECONDS=2" & REM Time in seconds, defaults to 2
::SET /A "_TARGET=%_WAIT_SECONDS%*80"
SET "_TARGET=12"
SET /A "_TARGET+=1"
SET "_START_TIME=%TIME%"
SET "_START_DATE=%DATE%"


PING -n %_TARGET% 127.0.0.1 > nul


:Measure
SET "_END_TIME=%TIME%"
SET "_END_DATE=%DATE%"
ECHO:
ECHO _WAIT_SECONDS = %_WAIT_SECONDS%
ECHO _TARGET = %_TARGET%
ECHO _START_TIME = %_START_TIME%
ECHO _END_TIME   = %_END_TIME%
CALL :ConvertTimeToSeconds "%_START_TIME%"
SET "_START_TIME_SECS=%_TIME_SECONDS%"
CALL :ConvertTimeToSeconds "%_END_TIME%"
SET "_END_TIME_SECS=%_TIME_SECONDS%"
IF NOT "%_START_DATE%"=="%_END_DATE%" (
	REM ECHO Next day^!
	REM PAUSE
	SET /A "_TIME_DIFF=86400-%_START_TIME_SECS%"
	SET /A "_TIME_DIFF+=%_END_TIME_SECS%"
) ELSE (
	SET /A "_TIME_DIFF=%_END_TIME_SECS%-%_START_TIME_SECS%"
)
::SET /A "_TIME_DIFF+=3600" & REM +60 mins
::SET /A "_TIME_DIFF+=4200" & REM +70 mins (1 hr 10 mins)
::SET /A "_TIME_DIFF+=86400" & REM +24 hrs
CALL :ConvertSecondsToTime "%_TIME_DIFF%"
ECHO Duration =    %_TIME_FORMATTED%
ECHO Duration = %_TIME_DURATION%
ECHO _WAIT_SECONDS = %_WAIT_SECONDS% sec
SET "_LOG=%~dpn0.csv" & REM This script's Drive letter, file Path, and file Name. https://ss64.com/nt/syntax-args.html
IF NOT EXIST "%_LOG%" ECHO _TARGET,_TIME_IN_SECONDS> "%_LOG%"
ECHO %_TARGET%,%_TIME_DIFF% >>"%_LOG%"
ECHO:
PAUSE

:END
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.

REM -------------------------------------------------------------------------------

:DefineFunctions
:: Declare Functions

::Index of functions: 
:: 1. :ConvertTimeToSeconds
:: 2. :ConvertSecondsToTime

GOTO SkipFunctions
:-------------------------------------------------------------------------------
:ConvertTimeToSeconds TimeValue [/D]
:: Takes a given 24-hour time input like " 5:47:23.52" or "21-31-39" and converts it into seconds
:: 		/D 	Include decimal calculations. If this switch is omitted any decimal values passed will be dropped.
:: Output: %_TIME_SECONDS%
@ECHO OFF
SETLOCAL
SET "_INPUT_TIME=%~1"
SET "_SEC_SWITCH=%~2"
:: https://ss64.com/nt/syntax-substring.html
:: Extract Hours (first 2 digits)
SET "_TIME_HOURS=%_INPUT_TIME:~0,2%"
:: Bugfix: Check if first digit in hours is a zero (e.g. 09) or blank
:: Extract the first character out of _TIME_HOURS
SET "_TIME_HOURS_FIRST=%_TIME_HOURS:~0,1%"
IF "%_TIME_HOURS_FIRST%"==" " (
	REM Set _TIME_HOURS to the second character (instead of first 2 digits of string)
	SET "_TIME_HOURS=%_INPUT_TIME:~1,1%"
) ELSE (
	IF "%_TIME_HOURS_FIRST%"=="0" (
		REM Bugfix: Cannot use ' IF %_TIME_HOURS_FIRST% EQU 0 ' since if the first character is a space, it will still fail with "0 was unexpected at this time." Must do a string compare.
		REM Set _TIME_HOURS to the second character (instead of first 2 digits of string)
		SET "_TIME_HOURS=%_INPUT_TIME:~1,1%"
	)
)
::ECHO Hour = %_TIME_HOURS%
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Extract Minutes (4th and 5th character)
SET "_TIME_MINS=%_INPUT_TIME:~3,2%"
:: Bugfix: Check if first digit in minutes is a zero (e.g. 09)
:: Extract the first character out of _TIME_MINS
SET "_TIME_MINS_FIRST=%_TIME_MINS:~0,1%"
IF %_TIME_MINS_FIRST% EQU 0 (
	REM Set _TIME_MINS to the 5th character, rather than the 4th and 5th characters
	SET "_TIME_MINS=%_INPUT_TIME:~4,1%"
)
::ECHO Mins = %_TIME_MINS%
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Extract Seconds (7th and 8th characters)
SET "_TIME_SECS=%_INPUT_TIME:~6,2%"
:: Bugfix: Check if first digit in seconds is a zero (e.g. 09)
:: Extract the first character out of _TIME_SECS
SET "_TIME_SECS_FIRST=%_TIME_SECS:~0,1%"
IF %_TIME_SECS_FIRST% EQU 0 (
	REM Extract the 8th character
	SET "_TIME_SECS=%_INPUT_TIME:~7,1%"
)
::ECHO Secs = %_TIME_SECS%
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Make hours into minutes (multiply by 60)
SET /A "_TIME_HOURS_MINS=%_TIME_HOURS%*60"
:: Add to minutes
SET /A "_TIME_MINS+=%_TIME_HOURS_MINS%"
:: Make minutes into seconds (multiply by 60)
SET /A "_TIME_MINS_SECS=%_TIME_MINS%*60"
:: Add to seconds
SET /A "_TIME_SECS+=%_TIME_MINS_SECS%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_SWITCH_LETTER=%_SEC_SWITCH:~1,1%"
IF /I "%_SWITCH_LETTER%"=="D" (
	REM Extract Seconds (everything after the 8th character)
	SET "_TIME_MILISECS=%_INPUT_TIME:~8%"
	REM Appends everything extracted (fractions of a second) to the end of our final seconds calculation.
	SET "_TIME_SECS=%_TIME_MINS_SECS%%_TIME_MILISECS%"
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_TIME_SECONDS=%_TIME_SECS%"
EXIT /B
:-------------------------------------------------------------------------------
:ConvertSecondsToTime TimeValInSeconds
:: Takes a value given in seconds and converts it into several time formats
:: Outputs:
:: "%_TIME_FORMATTED%" (will always be exactly 8 characters long) e.g. " 9:31:39"
:: "%_TIME_SORTABLE%" (will always be exactly 8 characters long) e.g. "09-31-39"
:: "%_TIME_DURATION%" (will always be exactly 12 characters long) e.g. "  9h 31m 39s" or "109h  7m  9s"
@ECHO OFF
SETLOCAL
SET "_INPUT_SECS=%~1"
:: https://ss64.com/nt/set.html
:: Get minutes from seconds
SET /A "_TIME_MINS=%_INPUT_SECS%/60"
:: Keep the remainder as seconds
SET /A "_TIME_SECS=%_INPUT_SECS%%%60"
:: Get hours from minutes
SET /A "_TIME_HOURS=%_TIME_MINS%/60"
:: Keep the remainder as minutes
SET /A "_TIME_MINS%%=60"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Format time like " 9:31:39" (FORMATTED)
IF %_TIME_HOURS% LSS 10 (SET "_FORM_HOURS= %_TIME_HOURS%") ELSE (SET "_FORM_HOURS=%_TIME_HOURS%")
IF %_TIME_MINS% LSS 10 (SET "_FORM_MINS=0%_TIME_MINS%") ELSE (SET "_FORM_MINS=%_TIME_MINS%")
IF %_TIME_SECS% LSS 10 (SET "_FORM_SECS=0%_TIME_SECS%") ELSE (SET "_FORM_SECS=%_TIME_SECS%")
SET "_FORM_TIME=%_FORM_HOURS%:%_FORM_MINS%:%_FORM_SECS%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Format time like "09-31-39" (SORTABLE)
IF %_TIME_HOURS% LSS 10 (SET "_SORT_HOURS=0%_TIME_HOURS%") ELSE (SET "_SORT_HOURS=%_TIME_HOURS%")
IF %_TIME_MINS% LSS 10 (SET "_SORT_MINS=0%_TIME_MINS%") ELSE (SET "_SORT_MINS=%_TIME_MINS%")
IF %_TIME_SECS% LSS 10 (SET "_SORT_SECS=0%_TIME_SECS%") ELSE (SET "_SORT_SECS=%_TIME_SECS%")
SET "_SORT_TIME=%_SORT_HOURS%-%_SORT_MINS%-%_SORT_SECS%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Format time like "  9h 31m 39s" (DURATION)
IF %_TIME_HOURS% LSS 100 (SET "_DUR_HOURS= %_TIME_HOURS%") ELSE (SET "_DUR_HOURS=%_TIME_HOURS%")
IF %_TIME_HOURS% LSS 10 (SET "_DUR_HOURS= %_DUR_HOURS%") ELSE (SET "_DUR_HOURS=%_DUR_HOURS%")
IF %_TIME_MINS% LSS 10 (SET "_DUR_MINS= %_TIME_MINS%") ELSE (SET "_DUR_MINS=%_TIME_MINS%")
IF %_TIME_SECS% LSS 10 (SET "_DUR_SECS= %_TIME_SECS%") ELSE (SET "_DUR_SECS=%_TIME_SECS%")
SET "_DUR_TIME=%_DUR_HOURS%h %_DUR_MINS%m %_DUR_SECS%s"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_TIME_FORMATTED=%_FORM_TIME%" & SET "_TIME_SORTABLE=%_SORT_TIME%" & SET "_TIME_DURATION=%_DUR_TIME%"
EXIT /B
:-------------------------------------------------------------------------------
:: End functions
:SkipFunctions

exit/b
:"Finish"
echo running code for %0
rem do stuff here
goto :Done
:"Suboption 1 1"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 1 2"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 1 3"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 2 1"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 2 2"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 3 1"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 3 2"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 3 3"
echo running code for %0
rem do stuff here
exit/b
:"Suboption 3 4"
echo running code for %0
rem do stuff here
exit/b

::---------------------------------------------------------------------------------------------------------------------------------
:choice
rem 1=title 2=options 3=output_variable                                          example: call :choice Choose "op1,op2,op3" result
setlocal & set "c=about:<title>%~1</title><head><script language='javascript'>window.moveTo(-200,-200);window.resizeTo(100,100);"
set "c=%c% </script><hta:application innerborder='no' sysmenu='yes' scroll='no'><style>body{background-color:#17141F;}"
set "c=%c% br{font-size:14px;vertical-align:-4px;} .button{background-color:#7D5BBE;border:2px solid #392E5C; color:white;"
set "c=%c% padding:4px 4px;text-align:center;text-decoration:none;display:inline-block;font-size:16px;cursor:pointer;"
set "c=%c% width:100%%;display:block;}</style></head><script language='javascript'>function choice(){"
set "c=%c% var opt=document.getElementById('options').value.split(','); var btn=document.getElementById('buttons');"
set "c=%c% for (o in opt){var b=document.createElement('button');b.className='button';b.onclick=function(){
set "c=%c% close(new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(this.value));};"
set "c=%c% b.appendChild(document.createTextNode(opt[o]));btn.appendChild(b);btn.appendChild(document.createElement('br'));};"
set "c=%c% btn.appendChild(document.createElement('br'));var r=window.parent.screen;"
set "c=%c% window.moveTo(r.availWidth/3,r.availHeight/6);window.resizeTo(r.availWidth/3,document.body.scrollHeight);}</script>"
set "c=%c% <body onload='choice()'><div id='buttons'/><input type='hidden' name='options' value='%~2'></body>"
for /f "usebackq tokens=* delims=" %%# in (`mshta "%c%"`) do set "choice_var=%%#"
endlocal & set "%~3=%choice_var%" & exit/b &rem snippet by AveYo released under MIT License
::-------------------------------------------------------------------------------------------------------------------------------- 