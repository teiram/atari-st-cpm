#!/usr/bin/python3

import getopt, sys, os, tempfile, subprocess

headersize = 28
tracksectors = 9
sectorsize = 512
trackcount = 80
tracksize = tracksectors * sectorsize

def tracks(l):
	for i in range(0, len(l), tracksize):
		s = l[i : i + tracksize]
		yield s + b'\xe5' * (tracksize - len(s)) 
		
def trackdata(data, tracksize):
	for i in range(0, len(data)//tracksize):
		yield data[tracksize * i: tracksize * (i + 1)]

def words(l):
	for i in range(0, 510, 2):
		yield l[i: i + 2]

def getbootloader(filename):
	with open(filename, "rb") as f:
		f.seek(headersize)
		data = f.read(510)
		x = words(data)
		value = 0
		for i in range(0, 510, 2):
			value += (data[i] << 8) | data[i + 1]
	checksum = (0x1234 - (value & 0xffff)) & 0xffff
	data += checksum.to_bytes(2, 'big')
	return data

def cpmtools():
	rcode = subprocess.call(args=['cpmcp', '-h'], stdout=subprocess.DEVNULL,
		stderr=subprocess.DEVNULL)
	return rcode == 1

def getfiles(utildir):
	#Files in utildir to user 0
	#Files in subdirs 1..15 to those user areas
	files = {}
	totalfiles = 0
	for userarea in range(0, 16):
		areadir = utildir if userarea == 0 else os.path.join(utildir, str(userarea))
		if os.path.isdir(areadir):
			areafiles = [os.path.join(areadir, f) for f in os.listdir(areadir) if os.path.isfile(os.path.join(areadir, f))]
			totalfiles += len(areafiles)
			files[userarea] = areafiles
		
	return totalfiles, files

utildir = None
sides = 2
opt, args = getopt.getopt(sys.argv[1:], "u:s")
for o, a in opt:
	if o == '-u':
		utildir = a
	if o == '-s':
		sides = 1

if (len(sys.argv) < 3):
	print("Usage: mkstdisk.py [-u utildir] bootsector cpm outputfile")
	exit(255)

bfile = args[0]
cpmfile = args[1]
ofile = args[2]
size = tracksize * trackcount * sides

print("Creating disk {} with bootloader={}, cpm={} and sides={}".format(ofile, bfile, cpmfile, sides))
data = getbootloader(bfile)
with open(cpmfile, "rb") as f:
	f.seek(headersize)
	data += f.read()

data += bytearray(b'\xe5') * (size - len(data))

if utildir:
	nfiles, files = getfiles(utildir)
	if nfiles > 0:
		if cpmtools():
			cpmtoolsformat = 'st68k-360' if sides == 1 else 'st68k-720'
			fp = tempfile.NamedTemporaryFile()
			fp.write(data)
			fp.flush()
			for key in files:
				if files[key] and len(files[key]) > 0:
					args = ['cpmcp', '-f', cpmtoolsformat, fp.name]
					args.extend(files[key])
					args.append('{}:'.format(key))
					rcode = subprocess.call(args)
					if rcode != 0:
						print("Error in cpmcp. Aborting")
						exit(255)
			with open(fp.name, "rb") as fi:
				data = fi.read()
		else:
			print("No cpmtools found. Skipping file injection")

with open(ofile, "wb") as fo:
	if sides == 1:
		fo.write(data)
	else:
		sidea = trackdata(data[0 : tracksize * trackcount], tracksize)
		sideb = trackdata(data[tracksize * trackcount : ], tracksize)
		for i, j in zip(sidea, sideb):
			fo.write(i)
			fo.write(j)



