@ECHO off
rem author: Dark Tron
rem requirements: ffmpeg (https://www.ffmpeg.org/)






rem promt the user and asaign variable
SET /p size=Choose file size in MB (10MB normal, 20MB pr0): 
SET /p audio=Do you want audio? (y/n):
SET /p resolution=Set resolution (720/1080/2160):

:nextFile
ECHO.
ECHO converting to mp4: %~1
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%~1" >tmp
SET /p duration=<tmp
rem size is in MB. I need to convert to bit. I could multipy with 1000 * 8 but 950 * 8 guarantees to be under the desired file size
rem if file size is still too big change 950 to 900 or even 800. The smaller -> the smaller the file size
SET /a "bitrate=(size*950*8/duration)"
ECHO bitrate: %bitrate%
ECHO duration: %duration%
ECHO.

IF /I "%audio%" EQU "y" (
	ffmpeg -y -i "%~1" -c:v libx264 -preset medium -b:v %bitrate%k -pass 1 -b:a 96k -f mp4 NUL
	ffmpeg -i "%~1" -c:v libx264 -vf scale=-1:%resolution% -preset medium -b:v %bitrate%k -pass 2 -b:a 96k "%~dpn1_%size%MB.mp4"
) ELSE (
	ffmpeg -y -i "%~1" -c:v libx264 -preset medium -b:v %bitrate%k -pass 1 -an -f mp4 NUL
	ffmpeg -i "%~1" -c:v libx264 -vf scale=-1:%resolution% -preset medium -b:v %bitrate%k -pass 2 -an "%~dpn1_%size%MB.mp4"
)

rem shift %3 tp %2, %2 to %1...
SHIFT
rem check if there is a next parameter:
IF NOT [%1] == [] ( goto nextFile )
goto end

:end
rem clear 1 pass data
del ffmpeg*
del tmp
pause
