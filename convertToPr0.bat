@ECHO off
REM author: Dark Tron
REM requirements: ffmpeg (https://www.ffmpeg.org/)

REM prompt the user and assign variable
SET /p size=Choose file size in MB (10MB normal, 20MB pr0):
if not defined size set size=10
SET /p audio=Do you want audio? (y/N):
if not defined audio set audio=n
SET /p resolution=Set resolution (720/1080/2160):
if not defined resolution set resolution=720

:nextFile
ECHO.
ECHO converting to mp4: %~1

REM calculate bitrate
for /F "usebackq" %%a in (`@ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%~1" 2^>^&1`) do set duration=%%a
for /f "tokens=1 delims=." %%a in ("%duration%") do set duration=%%a
REM size is in MB. I need to convert to bit. I could multiply with 1000 * 8. But 900 * 8 guarantees to be under the desired file size
REM if file size is still too big change 900 to 800. The smaller -> the smaller the file size
ECHO duration: %duration%s
SET /a "bitrate=(size*900*8/duration)"
ECHO bitrate: %bitrate%bit/s
ECHO.

REM audio or no audio?
IF /I "%audio%" EQU "y" (
  set audio=-b:a 96k
) ELSE (
  set audio=-an
)

REM convert
ffmpeg -y -i "%~1" -map_metadata -1 -c:v libx264 -profile:v main -level 4.0 -pix_fmt yuv420p -movflags +faststart -preset slow -b:v %bitrate%k -an -pass 1 -f mp4 NUL
ffmpeg -i "%~1" -map_metadata -1 -c:v libx264 -profile:v main -level 4.0 -pix_fmt yuv420p -movflags +faststart -vf scale=-1:%resolution% -preset slow -b:v %bitrate%k -c:a aac %audio% -pass 2 "%~dpn1_%size%MB.mp4"

REM shift to next file
SHIFT
REM check if there is a next file:
IF NOT [%1] == [] ( goto nextFile )

REM delete pass 1 data
del ffmpeg*.log*
pause
