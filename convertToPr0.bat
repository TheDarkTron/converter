@echo off
if defined DEBUG_LOGFILE echo on

REM ----------------------------------------------------------------------------------------------
REM @author     :   Dark Tron
REM @date       :   20.12.2019
REM @syntax     :   Rufe --help auf um die Kommandozeilenparameter Aufzurufen
REM @see        :   https://pr0gramm.com/top/3575323
REM @purpose    :   requirements: ffmpeg (https://www.ffmpeg.org/)
REM ----------------------------------------------------------------------------------------------

setlocal

echo %0 %*

REM ----------------------------------------------------------------------------------------------

REM /**
REM  * Self Variablen
REM  */

REM - Laufwerksbuchstaben
set SELF_DRIVE=%~d0

REM - Eigener Dateiname
set SELF_NAME=%~nx0

REM - Eigner Pfad
set SELF_PATH=%~p0
set SELF_PATH=%SELF_PATH:~0,-1%
set SELF_PATH=%SELF_DRIVE%%SELF_PATH%

REM - Eigenen Verzeichnisnamen
for %%i in ("%SELF_PATH%") do set SELF_DIRNAME=%%~ni

REM ----------------------------------------------------------------------------------------------

REM /**
REM  * Init Variablen
REM  */
set JUST_HELP=
set JUST_EXECUTE=
set JUST_AUDIO=
set THE_FFMPEG=ffmpeg.exe
set THE_FFPROBE=ffprobe.exe
set THE_FFMPEG_PATH=
set THE_SIZE=
set THE_INPUTFILES=
set THE_RESOLUTION=
set RC_executeFailed=1000
set RC_NoFilesFoundFailed=2000
set RC_FFMPEGNotFound=3000
set RC_FFPROBENotFound=4000
set RC=0

REM ----------------------------------------------------------------------------------------------

REM /**
REM  * Kommandozeilen Parameters einlesen
REM  */

set ARGV=%*
for %%i in (%ARGV%) do call:parseCommandlineArgument %%i

REM ----------------------------------------------------------------------------------------------

REM /**
REM  * Main
REM  */

    REM - Der Aufruf der Hilfe, danach wird das Programm beendet
    if defined JUST_HELP call:hilfe
    if defined JUST_HELP goto:ausstieg

    REM - Find the ffmpeg
    set fmpegpath=%THE_FFMPEG%
    if defined THE_FFMPEG_PATH set fmpegpath=%THE_FFMPEG_PATH%\%fmpegpath%
    call:locateExe THE_FFMPEG "%THE_FFMPEG%" "%fmpegpath%"
    if not defined THE_FFMPEG call:abort "ffmpeg not found" %RC_FFMPEGNotFound%&exit /b %RC_FFMPEGNotFound%

    REM - Find the ffprobe
    set fmpegpath=%THE_FFPROBE%
    if defined THE_FFMPEG_PATH set fmpegpath=%THE_FFMPEG_PATH%\%fmpegpath%
    call:locateExe THE_FFPROBE "%THE_FFPROBE%" "%fmpegpath%"
    if not defined THE_FFPROBE call:abort "ffprobe not found" %RC_FFPROBENotFound%&exit /b %RC_FFPROBENotFound%

    REM - check arguments
    call:CheckArguments

    REM - Führt den Convert aus
    if defined JUST_EXECUTE call:install "%THE_PACKETPATH%" "%JUST_INSTALL_FanucEdit%" "%JUST_INSTALL_VKRC_Editor%" "%JUST_INSTALL_Dongledriver%" "%JUST_INSTALL_VCRedist%" "%JUST_INSTALL_KeyManFlex%"
    if defined JUST_EXECUTE set RC=%ERRORLEVEL%
    if %RC% neq 0 call:abort "video convert failed" %RC_executeFailed%&exit /b %RC_executeFailed%

goto:ausstieg

REM ----------------------------------------------------------------------------------------------

:parseCommandlineArgument
REM /**
REM  * Auswertung, die Kommandozeilen Parameter
REM  * @param[in] arg (string) Einzelner Parameter
REM  */
    set arg=%~1

    if "%arg%" equ "--help" (set JUST_HELP=true&goto:eof)

    if "%arg%" equ "--execute" (set JUST_EXECUTE=true&goto:eof)

    if "%arg%" equ "--audio" (set JUST_AUDIO=true&goto:eof)

    set testarg=%arg:--size:=%
    if "%testarg%" neq "%arg%" (set THE_SIZE=%testarg%&goto:eof)

    set testarg=%arg:--resolution:=%
    if "%testarg%" neq "%arg%" (set THE_RESOLUTION=%testarg%&goto:eof)

    set testarg=%arg:--ffmpeg:=%
    if "%testarg%" neq "%arg%" (set THE_FFMPEG_PATH=%testarg%&goto:eof)

    set THE_INPUTFILES=%THE_INPUTFILE% "%arg%"

    set arg=
    set testarg=
goto:eof

REM ----------------------------------------------------------------------------------------------

:CheckArguments

if not defined THE_SIZE set /p THE_SIZE=Choose file size in MB (10MB normal, 20MB pr0): 
if not defined JUST_AUDIO set /p JUST_AUDIO=Do you want audio? (y/n): 
if not defined THE_RESOLUTION set /p THE_RESOLUTION=Set resolution (720/1080/2160): 

if "%JUST_AUDIO%" equ "n" set JUST_AUDIO=

goto:eof

REM ----------------------------------------------------------------------------------------------

:locateExe
REM /**
REM  * Findet eine exe
REM  * @param[out] result (string) Pfad zur exe
REM  * @param[in] anwendung (string) Der Name der Anwendung
REM  * @param[in] ersatzPath (string) Falls die Anwendung nicht auf direkt gefunden werden konnte, ein ersatz pfad in dem geschaut wird
REM  */
setlocal
    set result=
    set pathExe=
    set anwendung=%~2
    set ersatzPath=%~3

    for /f "tokens=*" %%a in ('where %anwendung% 2^>NUL') do set pathExe=%%a
    if not defined pathExe set pathExe=%ersatzPath%
    if exist "%pathExe%" set result=%pathExe%

endlocal&set %~1=%result%&exit /b 0

REM ----------------------------------------------------------------------------------------------

:convertFile
REM /**
REM  * Konventiert ein Video
REM  * @param[in] videofile (string) Der Pfad zur Videodatei
REM  * @param[in] outputFile (string) Der Pfad wo das ergebnis gespeichert werden soll
REM  * @return (int) Wenn 1000 wiedergeben wird wurde keine Datei gefunden, bei anderen returncodes gab ffmpeg ein fehler zurück
REM  */

setlocal
    set videofile=%~1
    set outputFile=%~2
    set bitrate=%~3
    set resolution=%~4
    set withAudio=%~5

    if not defined videofile endlocal&exit /b %RC_NoFilesFoundFailed%
    if not defined outputFile endlocal&exit /b %RC_NoFilesFoundFailed%
    if not exist "%videofile%" endlocal&exit /b %RC_NoFilesFoundFailed%

    set audio=-an
    if defined withAudio set audio=-b:a 96k

    set argumentsOne=-y -i "%~1" -c:v libx264 -preset medium -b:v %bitrate%k -pass 1 %audio% -f mp4>NUL
    set argumentsTwo=-i "%~1" -c:v libx264 -vf scale=-1:%resolution% -preset medium -b:v %bitrate%k -pass 2 %audio% "%outputFile%">NUL

    REM pushd "%packet_path%"

        "%THE_FFMPEG%" %argumentsOne%
        if "%ERRORLEVEL%" neq 0 exit /b %RC_executeFailed%

        "%THE_FFMPEG%" %argumentsTwo%
        if "%ERRORLEVEL%" neq 0 exit /b %RC_executeFailed%

    REM popd

endlocal&exit /b %rc%

REM ----------------------------------------------------------------------------------------------

:calculateBitrate
REM /**
REM  * Konventiert ein Video
REM  * @param[in] videofile (string) Der Pfad zur Videodatei
REM  * @param[in] Size (int) Die Size die das Video haben soll
REM  * @param[out] bitrate (int) Die Berechnete Bitrate des Videos
REM  * @return (int) Wenn 1000 wiedergeben wird wurde keine Datei gefunden, bei anderen returncodes gab ffmpeg ein fehler zurück
REM  */

setlocal
    set videofile=%~1
    set size=%~2
    set duration=
    set bitrate=

    if not defined videofile endlocal&exit /b %RC_NoFilesFoundFailed%
    if not exist "%videofile%" endlocal&exit /b %RC_NoFilesFoundFailed%

    set arguments=-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%videofile%"

    for /f "tokens=1" %%a in ('"%THE_FFPROBE%" %arguments%') do set duration=%%a
    if "%ERRORLEVEL%" neq 0 exit /b 1
    if not defined duration exit /b 2

    SET /a "bitrate=(%size%*950*8/%duration%)"

endlocal&set %~3=%bitrate%&exit /b 0

REM ----------------------------------------------------------------------------------------------

:execute
REM /**
REM  * Konventiert ein Liste von Videos
REM  * @param[in] videofiles (List^<string^>) Eine Liste von Videos
REM  */
setlocal

set videofiles=%*
for %%i in (%videofiles%) do call:executeOneFile %%i

endlocal&exit /b 0

REM ----------------------------------------------------------------------------------------------

:executeOneFile
REM /**
REM  * Konventiert ein Video, wird von einem foreach aufgerufen
REM  * @param[in] videofile string) Ein Video
REM  */
setlocal
    set videofile=%~1
    set outputFile="%~dpn1_%size%MB.mp4"
    set bitrate=
    set size=%THE_SIZE%
    set resolution=%THE_RESOLUTION%
    set withAudio=%JUST_AUDIO%

    call:calculateBitrate "%videofile%" "%size%" bitrate
    set rc=%ERRORLEVEL%
    if "%rc%" neq "0" endlocal&exit /b %rc%

    call:convertFile "%videofile%" "%outputFile%" "%bitrate%" "%resolution%" "%withAudio%"
    set rc=%ERRORLEVEL%
    if "%rc%" neq "0" endlocal&exit /b %rc%

endlocal&exit /b 0

REM ----------------------------------------------------------------------------------------------

:hilfe
REM /**
REM  * Gibt die Hilfe in der Console aus
REM  */
setlocal

    echo.%SELF_NAME% videoInput.mp4 --execute "--size:10MB" "--resoultion:720" "--ffmpeg:C:\Users\n0vu2\Downloads\ffmpeg-20191217-bd83191-win64-static\ffmpeg-20191217-bd83191-win64-static\bin"
    echo.%SELF_NAME% --help
    echo.
    echo. --execute            Der Befehl zum ausführen
    echo. --audio              Mit der Angabe dieses Commands wird audio enthalten sein
    echo. --size:^<size^>      Choose file size in MB (10MB normal, 20MB pr0)
    echo.         10MB         normal
    echo.         20MB         pr0
    echo. --resolution:^<r^>   Set resolution (720/1080/2160)
    echo.          720         HD
    echo.         1080         FullHD
    echo.         2160         2K
    echo. --ffmpeg:^<path^>    Der Pfad in der die ffmpeg.exe liegt
    echo.
    echo. --targetpath:^<path^>  Der Zielpfad für den Output
    echo.                      Default: "..."

    pause

endlocal&goto:eof

REM ----------------------------------------------------------------------------------------------

:ausstieg
REM /**
REM  * Der Aussteigspunkt der Anwendung
REM  */

echo off
echo.
echo. RC:%RC%
echo. Work ended at: %TIME%
echo.
echo. ************************************ [ Work wurde beendet ] ************************************
echo.

exit /b %RC%

REM ----------------------------------------------------------------------------------------------

:abort
REM /**
REM  * Der Aussteigspunkt der Anwendung bei einem Fehler
REM  */
set errormessage=%~1
set abortrc=%~2

echo off
echo. Message: %errormessage%
echo. RC: %abortrc%
echo. Work ended at: %TIME%
echo.
echo. ************************************ [ Work wurde FEHLERHAFT beendet ] ************************************
echo.

exit /b %abortrc%

REM ----------------------------------------------------------------------------------------------

REM -- [EOF] --
