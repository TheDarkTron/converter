@ECHO off
:start
ECHO.
ECHO 1. Save to Desktop
ECHO 2. Save to source directory
ECHO.
set choice=
rem promt the user and asaign variable "choice"
set /p choice=Make your choice: 
rem crop the first character
if not '%choice%'=='' set choice=%choice:~0,1%
rem goto places
if '%choice%'=='1' goto desktop
if '%choice%'=='2' goto directory
rem error and restart
ECHO "%choice%" is not valid, try again
ECHO.
goto start


:desktop
ECHO.
ECHO Saving to Desktop
:nextFileDesk
ECHO.
ECHO converting to wav:
rem %1 is the first drag drop parameter. The "~" removes special chracters
ECHO "%~1"
ECHO.
rem % (Variable) ~ (remove special Chars) d (Drive Letter) p (Path) n (Filename) x (Extension)
lame --decode "%~1" "C:\Users\TheDa\Desktop\%~n1.wav"
rem shift %3 tp %2, %2 to %1...
SHIFT
rem check if there is a next parameter:
IF NOT [%1] == [] ( goto nextFileDesk )
goto end


:directory
ECHO.
ECHO Saving to source directory
:nextFileDir
ECHO.
ECHO converting to wav:
rem %1 is the first drag drop parameter. The "~" removes special chracters
ECHO "%~1"
ECHO.
rem % (Variable) ~ (remove special Chars) d (Drive Letter) p (Path) n (Filename) x (Extension)
lame --decode "%~1" "%~dpn1.wav"
rem shift %3 tp %2, %2 to %1...
SHIFT
rem check if there is a next parameter:
IF NOT [%1] == [] ( goto nextFileDir )
goto end


:end
pause