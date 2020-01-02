@ECHO off
:nextFile
ECHO.
ECHO converting to mp4:
rem %1 is the first drag drop parameter. The "~" removes special chracters
ECHO "%~1"
ECHO.

ffmpeg -n -hwaccel auto -i "%~1" -c:v libx265 -crf 28 -tune film -threads 7 "%~dpn1_small.mp4"

rem shift %3 tp %2, %2 to %1...
SHIFT
rem check if there is a next parameter:
IF NOT [%1] == [] ( goto nextFile )
goto end

:end
pause