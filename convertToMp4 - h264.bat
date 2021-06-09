@ECHO off
:nextFile
ECHO.
ECHO converting to mp4: "%~1"
REM %1 is the first drag drop parameter. The "~" removes special chracters
ECHO.

REM ffmpeg -n -hwaccel auto -i "%~1" -movflags use_metadata_tags -c:v libx264 -tune film -c:a copy -threads 7 "%~dpn1_small.mp4"
ffmpeg -n -hwaccel auto -i "%~1" -movflags use_metadata_tags -c:v h264_nvenc -preset slow -b:v 25M -maxrate:v 50M -bufsize:v 50M -c:a copy "%~dpn1_small.mp4"

REM shift to next file
SHIFT
REM check if there is a next file
IF NOT [%1] == [] ( goto nextFile )

ECHO conversion complete
PAUSE
