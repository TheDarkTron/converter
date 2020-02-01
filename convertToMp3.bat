@ECHO off
:start
ECHO.
ECHO 1. Save to Desktop
ECHO 2. Save to source directory
ECHO.
set choice=
REM promt the user and asaign variable "choice"
set /p choice=Make your choice:
REM crop the first character
if not '%choice%'=='' set choice=%choice:~0,1%
REM goto places
if '%choice%'=='1' goto desktop
if '%choice%'=='2' goto directory
REM error and restart
ECHO "%choice%" is not valid, try again
ECHO.
goto start


:desktop
ECHO.
ECHO Saving to Desktop
:nextFileDesk
ECHO.
ECHO converting to mp3:
REM %1 is the first drag drop parameter. The "~" removes special chracters
ECHO "%~1"
ECHO.
REM % (Variable) ~ (remove special Chars) d (Drive Letter) p (Path) n (Filename) x (Extension)
lame --preset insane "%~1" "C:\Users\TheDa\Desktop\%~n1.mp3"
REM shift %3 tp %2, %2 to %1...
SHIFT
REM check if there is a next parameter:
IF NOT [%1] == [] ( goto nextFileDesk )
goto end


:directory
ECHO.
ECHO Saving to source directory
:nextFileDir
ECHO.
ECHO converting to mp3:
REM %1 is the first drag drop parameter. The "~" removes special chracters
ECHO "%~1"
ECHO.
REM % (Variable) ~ (remove special Chars) d (Drive Letter) p (Path) n (Filename) x (Extension)
lame --preset insane "%~1" "%~dpn1.mp3"
REM shift to next file
SHIFT
REM check if there is a next file
IF NOT [%1] == [] ( goto nextFileDir )

pause
