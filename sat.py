import predict
from datetime import datetime
from subprocess import call
call(["sh", "updatesats.sh"])

sat = 'AO-07'
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
#1 07530U 74089B   18229.47395663 -.00000029  00000-0  10090-3 0  9993
#2 07530 101.6924 195.8893 0011742 215.6162 257.6255 12.53633834  2272"""
#Latitude longitude in degress

qth = (43.32, -1.98, 7)  # lat (N), long (W), alt (meters)
p = predict.transits(tle, qth)
for i in range(1,10):
	transit = p.next()
        ts=int(transit.start)
        print(datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S'))
	print("%f\t%f\t%f" % (transit.start, transit.duration(), transit.peak()['elevation']))