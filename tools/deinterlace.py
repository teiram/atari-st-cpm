#!/usr/bin/python3

import getopt, sys

def track_data(data, tracksize):
	for i in range(0, len(data)//tracksize):
		yield data[tracksize * i: tracksize * (i + 1)]

opt, args = getopt.getopt(sys.argv[1:], "o:")
for o, a in opt:
	if o == '-o':
		offset = int(a)

sectors = 9
tracks = 80
sectorsize = 512
opt, args = getopt.getopt(sys.argv[1:], "n:t:s:")
for o, a in opt:
	if o == '-n':
		sectors = int(a)
	if o == '-t':
		tracks = int(a)
	if o == '-s':
		sectorsize = int(a)

tracksize = sectorsize * sectors

if (len(sys.argv) < 2):
	print("Usage: deinterlace.py [-n spt][-t tracks][-s ssize] infile outfile")
	exit(255)

ifile = args[0]
ofile = args[1]
sidea = bytearray()
sideb = bytearray()
with open(ifile, "rb") as fi:
	for i in range(0, tracks):
		sidea.extend(fi.read(tracksize))
		sideb.extend(fi.read(tracksize))

	with open(ofile, "wb") as fo:
		fo.write(sidea)
		fo.write(sideb)

