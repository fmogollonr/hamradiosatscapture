#!/bin/sh
#input frecuency in MHz
export TZ=Etc/Zulu
timeout=$2
fecha=`date +%Y%m%d_%H%M%S`
freq=$1
sat=$3
locator="IN93ah"
rtmpkey="x"
squelch=120
monitor=`pactl list | grep -A2 "Source #" | grep analog | grep monitor | awk '{print $2}'`
#rtl_fm -l $squelch -f "$freq"M -M fm -g 50 -s 12.5k | gst-launch-1.0 videotestsrc pattern=2 is-live=1 ! videoconvert ! "video/x-raw, width=1280, height=720, framerate=30/1" !  clockoverlay font-desc="Sans, 24" text="$sat over $locator " time-format="    %Y-%m-%d %H:%M:%S utc" !  queue ! x264enc bitrate=1000 byte-stream=false key-int-max=60 bframes=0 aud=true tune=zerolatency ! "video/x-h264,profile=main" !  flvmux streamable=true name=mux ! rtmpsink location="rtmp://a.rtmp.youtube.com/live2/x/$rtmpkey app=live2" fdsrc do-timestamp=true ! audio/x-raw, format=S16LE, channels=1, layout=interleaved, rate=12500 ! audioconvert ! audiorate ! audioresample  ! tee name=tee ! "audio/x-raw, format=(string)S16LE, endianness=(int)1234,signed=(boolean)true, width=(int)16, depth=(int)16, rate=(int)44100,channels=(int)1" ! queue  ! voaacenc bitrate=128000 ! queue ! aacparse ! queue ! mux.  tee. ! lamemp3enc ! filesink location="$sat""$fecha"_"$freq"MHZ.mp3 
#rtl_fm -l $squelch -f "$freq"M -M fm -g 50 -s 16k | gst-launch-1.0 fdsrc do-timestamp=true ! audio/x-raw, format=S16LE,channels=1 , layout=interleaved, rate=16000 ! lamemp3enc ! filesink location="$sat""$fecha"_"$freq"MHZ.mp3
rtl_fm -l $squelch -f "$freq"M -M fm -s 8k - | gst-launch-1.0 -e videotestsrc pattern=2 is-live=1 ! videoconvert ! "video/x-raw, width=480, height=360, framerate=30/1" !  clockoverlay font-desc="Sans, 24" text="$sat over $locator on $freq MHz" time-format="    %Y-%m-%d %H:%M:%S utc" !  queue ! x264enc bitrate=1000 byte-stream=false key-int-max=60 bframes=0 aud=true tune=zerolatency ! "video/x-h264,profile=main" !  flvmux streamable=true name=mux ! rtmpsink location="rtmp://a.rtmp.youtube.com/live2/x/$rtmpkey app=live2"  fdsrc do-timestamp=true ! audio/x-raw, format=S16LE, channels=1, layout=interleaved, rate=8000 ! audioconvert ! queue ! tee name=tee ! queue ! voaacenc bitrate=12000 ! queue ! aacparse ! queue ! mux.  tee. ! lamemp3enc ! filesink location="$sat""$fecha"_"$freq"MHZ.mp3  &
#alsa_output.pci-0000_00_1f.3.analog-stereo.monitor
#rtl_fm -l $squelch -f "$freq"M -M fm -g 50 -s 12.5k | gst-launch-1.0 fdsrc do-timestamp=true ! audio/x-raw, format=S16LE, channels=1, layout=interleaved, rate=12500 ! autoaudiosink &
#gst-launch-1.0 videotestsrc pattern=2 is-live=1 ! videoconvert ! "video/x-raw, width=1280, height=720, framerate=25/1" !  clockoverlay font-desc="Sans, 24" text="$sat over $locator " time-format="    %Y-%m-%d %H:%M:%S utc" !  queue ! x264enc bitrate=1000 byte-stream=false key-int-max=60 bframes=0 aud=true tune=zerolatency ! "video/x-h264,profile=main" !  flvmux streamable=true name=mux ! rtmpsink location="rtmp://a.rtmp.youtube.com/live2/x/$rtmpkey app=live2"  pulsesrc device="$monitor" ! audioconvert ! queue ! tee name=tee ! queue ! voaacenc bitrate=128000 ! queue ! aacparse ! queue ! mux.  tee. ! lamemp3enc ! filesink location="$sat""$fecha"_"$freq"MHZ.mp3 &
#rtl_fm -l $squelch -f "$freq"M -M fm -g 50 -s 12.5k | gst-launch-1.0 fdsrc do-timestamp=true ! audio/x-raw, format=S16LE, channels=1, layout=interleaved, rate=12500 ! audioresample ! queue ! lamemp3enc ! filesink location="$sat""$fecha"_"$freq"MHZ.mp3 &

rtl_pid=`ps aux | grep rtl_fm | grep $freq | awk {'print $2'}`
gst_pid=`ps aux | grep gst-launch-1.0 | grep $fecha | awk {'print $2'}`
#gst_pid2=`ps aux | grep gst-launch-1.0 | grep device | awk {'print $2'}`

sleep $timeout

kill $rtl_pid
kill $gst_pid
#kill $gst_pid2

sleep 60

python sat.py $sat