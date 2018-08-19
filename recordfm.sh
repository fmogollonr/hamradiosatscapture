#!/bin/sh
#input frecuency in MHz
export TZ=Etc/Zulu
timeout=50
fecha=`date +%Y%m%d_%H%M%S`
freq=$1
squelch=0
rtl_fm -l $squelch -f "$freq"M -M fm -g 50 -s 12.5k | gst-launch-1.0 fdsrc ! audio/x-raw, format=S16LE, channels=1, layout=interleaved, rate=12500 ! audioresample ! queue ! tee name=late ! queue ! lamemp3enc ! filesink location="$fecha"_"$freq"MHZ.mp3 late. ! autoaudiosink videotestsrc pattern=2 ! video/x-raw-yuv,width=1280,height=720,framerate=30/1  ! x264enc key-int-max=60  ! h264parse  ! flvmux name=mux  late.  ! avenc_aac ! aacparse ! mux.     mux. ! rtmpsink location="rtmp://<stream-server-url>/" &

rtl_pid=`ps aux | grep rtl_fm | grep $freq | awk {'print $2'}`
gst_pid=`ps aux | grep gst-launch-1.0 | grep $fecha | awk {'print $2'}`

sleep $timeout

kill $rtl_pid
kill $gst_pid