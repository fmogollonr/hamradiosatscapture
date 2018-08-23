#!/bin/sh
#input frecuency in MHz
export TZ=Etc/Zulu
timeout=$2
fecha=`date +%Y%m%d_%H%M%S`
freq=$1
sat=$3
locator=`cat config.cfg | grep locator: | awk -F  ":" '{print $2}'`
rtmpkey="`cat config.cfg | grep rtmpkey: | awk -F  ":" '{print $2}'`"
squelch=0

echo $locator
echo $rtmpkey

wget -q --spider http://google.com
if [ $? -eq 0 ]; then
    ffmpegprinttimefilter="settb=AVTB,setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)',drawtext=text='$sat at $freq MHz $locator %{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d}':fontsize=18: fontcolor=yellow@0.8: box=1: boxcolor=blue@0.9"
    rtl_fm  -f "$freq"M -M fm -s 12.5k  -r 12.5k - | ffmpeg  -hide_banner -re -t $timeout -s 480x360 -f rawvideo -pix_fmt rgb24 -r 30 -i /dev/zero -f s16le -ac 1 -ar 12.5k -i pipe:0 -vf "$ffmpegprinttimefilter" -vcodec libx264 -preset veryfast -acodec libmp3lame -b:a 128k -ar 44100 -f flv rtmp://a.rtmp.youtube.com/live2/$rtmpkey -codec:a libmp3lame -b:a 128k "$sat""$fecha"_"$freq"MHZ.mp3 &
else
    ffmpegprinttimefilter="settb=AVTB,setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)',drawtext=text='$sat at $freq MHz $locator %{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d}':fontsize=18: fontcolor=yellow@0.8: box=1: boxcolor=blue@0.9"
    rtl_fm  -f "$freq"M -M fm -s 12.5k  -r 12.5k - | ffmpeg  -hide_banner -t $timeout -f s16le -ac 1 -ar 12.5k -i pipe:0 -codec:a libmp3lame -b:a 128k "$sat""$fecha"_"$freq"MHZ.mp3 &
fi


rtl_pid=`ps aux | grep rtl_fm | grep $freq | awk {'print $2'}`


sleep $timeout
sleep 10
kill $rtl_pid

echo "python sat.py $sat" | at now +1 minute