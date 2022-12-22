#!/usr/bin/env python

#
# Creates (*.KCC) file format from binary file.
#
# http://hc-ddr.hucki.net/wiki/doku.php/z9001:kassettenformate
#

import sys
import os
import ntpath

# write block
def setup_header(name, type, load_addr, start_addr, size):

	# create header buffer
	header = bytearray(128)

	# entry name
	for i in range(min(8, len(name))):
		header[i] = name[i]

	# entry type
	for i in range(min(3, len(type))):
		header[i + 8] = type[i]

	# entry parameter count
	if start_addr != None:
		header[16] = 3
	else:
		header[16] = 2

	# entry load address
	addr = 0
	if load_addr.startswith("0x"):
		addr = int(load_addr[2:], 16)
	elif load_addr.endswith("H"):
		addr = int(load_addr[:-1], 16)
	else:
		addr = int(load_addr)

	header[17] = addr & 0xff
	header[18] = (addr >> 8) & 0xff

	# entry end address
	addr = addr + size

	header[19] = addr & 0xff
	header[20] = (addr >> 8) & 0xff

	if start_addr != None:

		# entry start address
		addr = 0
		if start_addr.startswith("0x"):
			addr = int(start_addr[2:], 16)
		elif start_addr.endswith("H"):
			addr = int(start_addr[:-1], 16)
		else:
			addr = int(start_addr)

		header[21] = addr & 0xff
		header[22] = (addr >> 8) & 0xff

	return header

# command line parameters

USAGE = "USAGE: " + ntpath.basename(sys.argv[0]) + " <binary file> <name> <type> <load address> [start address]\n"

if len(sys.argv) < 5 or len(sys.argv) > 6:
	sys.stderr.write(USAGE)
	sys.exit(1)

# read original file

size = os.path.getsize(sys.argv[1]); # raises error if file does not exist

with open(sys.argv[1], "rb") as f:

	# setup header
	header = setup_header(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5] if len(sys.argv) > 5 else None, size)

	# write header
	sys.stdout.write(header)

	# read original file data
	data = f.read(size)

	# write file data
	sys.stdout.write(data)

	# pad data to multiple of 128 bytes
	pad_size = 128 - size % 128
	if pad_size != 128:
		sys.stdout.write(bytearray(pad_size))

