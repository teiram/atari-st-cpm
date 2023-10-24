#!/usr/bin/python3

import getopt, sys

def track_data(data, tracksize):
	for i in range(0, len(data)//tracksize):
		yield data[tracksize * i: tracksize * (i + 1)]


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
	print("Usage: interlace.py [-n spt][-t tracks][-s ssize] infile outfile")
	exit(255)

ifile = args[0]
ofile = args[1]

with open(ifile, "rb") as fi:
	sidea = track_data(fi.read(tracksize * tracks), tracksize)
	sideb = track_data(fi.read(tracksize * tracks), tracksize)

	with open(ofile, "wb") as fo:
		for i, j in zip(sidea, sideb):
			fo.write(i)
			fo.write(j)

