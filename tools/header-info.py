#!/usr/bin/python3

import sys, getopt

def getsymbols(f, size):
	data = f.read(size)
	for i in range(0, size, 14):
		sname = str(data[i: i + 8].strip(b'\x00'), 'ASCII')
		stype = int.from_bytes(data[i + 8: i + 10], byteorder='big')
		saddr = int.from_bytes(data[i + 10: i + 14], byteorder='big')
		yield (sname, stype, saddr)

showsymbols = False
showrelocinfo = True

opt, args = getopt.getopt(sys.argv[1:], "u:s")
for o, a in opt:
	if o == '-s':
		showsymbols=True

if (len(sys.argv) < 2):
	print("Usage: header-info.py [-s] file")
	exit(255)

with open(args[0], "rb") as f:
	data = f.read(36)			#Max header length
	magic = int.from_bytes(data[0: 2], byteorder='big')
	if magic != 0x601a and magic != 0x601b:
		print("Invalid header")
		exit(255)

	textsize = int.from_bytes(data[2: 6], byteorder='big')
	datasize = int.from_bytes(data[6: 10], byteorder='big')
	bsssize = int.from_bytes(data[10: 14], byteorder='big')
	symsize = int.from_bytes(data[14: 18], byteorder='big')
	textaddr = int.from_bytes(data[22: 26], byteorder='big')
	relocinfo = int.from_bytes(data[26: 28], byteorder='big')
	
	hassymbols = True if symsize > 0 else False
	hasrelocinfo = True if relocinfo == 0 else False
	headersize = 28 if magic == 0x601a else 36

	print("\nHeader of: %s" % args[0])
	print("-------------------------------------")
	print("Contiguous segments: %s" % ("Yes" if magic == 0x601a else "No"))
	print("Has reloc bits:\t%8s" % ("Yes" if relocinfo == 0 else "No"))

	print("Text size: \t%8d (0x%08x)" % (textsize, textsize))
	print("Data size: \t%8d (0x%08x)" % (datasize, datasize))
	print("Text + Data: \t%8d (0x%08x)" % (textsize + datasize, textsize + datasize))
	print("BSS size: \t%8d (0x%08x)" % (bsssize, bsssize))
	print("Symbols size: \t%8d (0x%08x)" % (symsize, symsize))
	print("Start address: \t%8d (0x%08x)" % (textaddr, textaddr))
	if magic == 0x601a:
		endaddr = textaddr + textsize + datasize + bsssize
		print("End address: \t%8d (0x%08x)" % (endaddr, endaddr))

	if magic == 0x601b:
		datastart = int.from_bytes(data[28: 32], byteorder='big')
		bssstart = int.from_bytes(data[32: 36], byteorder='big')
		textendaddr = textaddr + textsize - 1
		dataendaddr = datastart + datasize - 1
		bssendaddr = bssstart + bsssize - 1
	else:
		datastart = textaddr + textsize
		bssstart = datastart + datasize
		dataendaddr = bssstart - 1
		textendaddr = datastart - 1
		bssendaddr = bssstart + bsssize - 1
		print("Text from \t%8d (0x%08x) to %8d (0x%08x)" % (textaddr, textaddr, textendaddr, textendaddr))
		print("Data from \t%8d (0x%08x) to %8d (0x%08x)" % (datastart, datastart, dataendaddr, dataendaddr))
		print("BSS from \t%8d (0x%08x) to %8d (0x%08x)" % (bssstart, bssstart, bssendaddr, bssendaddr))


	if hassymbols and showsymbols:
		symboladdr = textaddr + textsize + datasize if magic == 0x601a else datastart + datasize
		f.seek(symboladdr + headersize)
		print("Symbol\t\tType\tAddress")
		print("---------------------------------")
		for symbol in getsymbols(f, symsize):
			print("%8s\t$%04x\t$%08x" % (symbol))
	if hasrelocinfo and showrelocinfo:
		relocaddr = textaddr + textsize + datasize + symsize if magic == 0x601a else datastart + datasize + symsize
		f.seek(headersize + relocaddr)
		relocdatasize = len(f.read())

		print("Reloc data size:%8d (0x%08x)" % (relocdatasize, relocdatasize))
		if relocdatasize < textsize + datasize:
			print("W: Reloc data seems to be incomplete")