#python called similar to
#python sat.py ISS 43.32 -1.98 7
#python sat.py <satname> <latitude> <longitude> <altitude>
import predict
from datetime import datetime
from subprocess import call
import subprocess
import sys
import os
import urllib2
from urllib2 import HTTPError
from urllib2 import URLError


#update tle from internet
url = 'https://www.amsat.org/tle/current/nasa.all'
try:
        filedata = urllib2.urlopen(url)  
except HTTPError, e:
        print ("error, no internet")
except URLError, e:
        print ("error, no internet")
else:
        datatowrite = filedata.read()
        with open('nasa.all', 'wb') as f:  
                f.write(datatowrite)


sat = sys.argv[1]
lat = 0
longitude = 0
alt = 0
matching=0
tle1=""
tle2=""
with open("config.cfg") as myFile:
    for num, line in enumerate(myFile, 1):
        if "lat" in line:
                lat=line.split(":")[1]
        elif "long" in line:
                longitude=line.split(":")[1]
        elif "alt" in line:
                alt=line.split(":")[1]


with open("nasa.all") as myFile:
    for num, line in enumerate(myFile, 1):
        if sat in line:
                matching=num

with open("nasa.all") as myFile:
    for num, line in enumerate(myFile, 1):
        if num == matching + 1:
                tle1=line
        if num == matching + 2:
                tle2=line


#Satellite frequencies list from https://www.amsat.org/fm-satellite-frequency-summary/:
#Los ssb para la siguiente tanda
freq="0"
if sat == "AO-85":
        freq="145.980"
elif sat == "AO-91":
        freq="145.960"
elif sat == "AO-92":
        freq="145.880"
elif sat == "SO-50":
        freq="436.795"                
elif sat == "LILACSAT-2":
        freq="437.200 "
elif sat == "IO-86":
        freq="435.880"
elif sat == "ISS":
        freq="145.800"


#Two elements data from any satellite or object
tle = "%s\n%s%s" %(sat,tle1,tle2)
#Latitude longitude in degress
print "Buscando para %s %s %s" %(lat.rstrip(),longitude.rstrip(),alt.rstrip())
qth = (lat.rstrip(), longitude.rstrip(), alt.rstrip())  # lat (N), long (W), alt (meters)
p = predict.transits(tle, qth)
for i in range(1,2):
	transit = p.next()
        ts=int(transit.start)
        #print(datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
        #print(datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
        day=datetime.fromtimestamp(ts).strftime('%Y-%m-%d')
        hour=datetime.fromtimestamp(ts).strftime('%H:%M')
        
        tmpduration=str(transit.duration()).split(".")
        # Add an extra minute to recording to ensure all conversation will be captured
        duration=int(tmpduration[0])+60
        
        commandline="/bin/echo './recordfm.sh %s %s %s' | at %s %s" %(freq,duration,sat,hour,day)

        print commandline
        subprocess.call(commandline, shell=True) 
        #os.system("/bin/bash -c %s"%commandline)
        #print(datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
	#print("%f\t%f\t%f" % (transit.start, transit.duration(), transit.peak()['elevation']))
