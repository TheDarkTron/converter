@ECHO off
:nextFile
ECHO.
ECHO converting to mp4: "%~1"
REM %1 is the first drag drop parameter. The "~" removes special chracters
ECHO.

ffmpeg -n -hwaccel auto -i "%~1" -movflags use_metadata_tags -c:v libx265 -crf 28 -tag:v hvc1 -threads 7 "%~dpn1_HEVC.mp4"

REM shift to next file
SHIFT
REM check if there is a next file
IF NOT [%1] == [] ( goto nextFile )

ECHO conversion complete
PAUSE
