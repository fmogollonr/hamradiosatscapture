#python called similar to
#python sat.py ISS 43.32 -1.98 7
#python sat.py <satname> <latitude> <longitude> <altitude>
import predict
from datetime import datetime
from subprocess import call
import sys

#update tle from internet
call(["sh", "updatesats.sh"])

sat = sys.argv[1]
lat = sys.argv[2]
longitude = sys.argv[3]
alt = sys.argv[4]
matching=0
tle1=""
tle2=""
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
qth = (lat, longitude, alt)  # lat (N), long (W), alt (meters)
p = predict.transits(tle, qth)
for i in range(1,2):
	transit = p.next()
        ts=int(transit.start)
        #print(datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
        #print(datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
        day=datetime.fromtimestamp(ts).strftime('%Y-%m-%d')
        hour=datetime.fromtimestamp(ts).strftime('%H:%M')
        commandline="echo './recordfm.sh %s %s' | at %s %s" %(freq,sat,day,hour)
        print commandline
        #print(datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
	#print("%f\t%f\t%f" % (transit.start, transit.duration(), transit.peak()['elevation']))
