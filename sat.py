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


#Two elements data from any satellite or object
tle = "%s\n%s%s" %(sat,tle1,tle2)
#Latitude longitude in degress
qth = (lat, longitude, alt)  # lat (N), long (W), alt (meters)
p = predict.transits(tle, qth)
for i in range(1,10):
	transit = p.next()
        ts=int(transit.start)
        print(datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
	print("%f\t%f\t%f" % (transit.start, transit.duration(), transit.peak()['elevation']))
