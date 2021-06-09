@ECHO off
:nextFile
ECHO.
ECHO converting to mp4: "%~1"
REM %1 is the first drag drop parameter. The "~" removes special chracters
ECHO.

ffmpeg -n -hwaccel auto -i "%~1" -c:v libx265 -crf 30 -filter_complex "fps=30,scale=-1:ih*min(1\,1080/ih)" -tag:v hvc1 -b:a 64k -threads 7 "%~dpn1_really_small.mp4"

REM shift to next file
SHIFT
REM check if there is a next file
IF NOT [%1] == [] ( goto nextFile )

ECHO conversion complete
pause
