# Scripts
Praktische Scripts für den Alltag, was man halt so braucht, Hauptsächlich convertier Kram. Für etwaige Schäden wird nicht gehaftet bla bla...

## Requirements:
- ffmpeg
- lame

## Usage:
Einfach Drag & Drop drauf da die Scheiße.

## Description
|convertToMp3.bat                       | converts the input to mp3 with lame with the insane preset (320kbits)|
|convertToMp3.sh                        | converts the input to mp3 with lame with the insane preset (320kbits)|
|convertToMp4 - h264                    | converts to mp4 with h264 codec with ffmpeg|
|convertToMp4 - h265 - normalize audio  | converts to mp4 with h265 codec with ffmpeg and normalizes the audio|
|convertToMp4 - h265                    | converts to mp4 with h265 codec with ffmpeg|
|convertToMp4 - rotate 180              | converts to mp4 with h265 codec with ffmpeg and rotates the video 180°|
|convertToPr0                           | converts to mp4 with h264 codec with profile main and level 4.0, also strips metadata and enables fast start. Allows you to choose the output file size|
|convertToRealySmallMp4 - h265          | converts to mp4 with h265 codec. Scales down to max HD (1080p) 30fps. 64kbits audio. CRF 30|
|convertToWav                           | converts to wav with lame|
|extractAudio                           | extracts audio from video by ffmpeg|
