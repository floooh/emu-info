#!/usr/bin/env python

# Converter for 16 bit signed *.WAV files or 8 bit unsigned Amiga samples
# The result is 4 bit packed into one byte.

import sys
import ntpath
import math

USAGE = "USAGE: " + ntpath.basename(sys.argv[0]) + " <in-file> <out-file> [-d]\n"

if len(sys.argv) != 3 and len(sys.argv) != 4:
	sys.stderr.write(USAGE)
	sys.exit(1)

COMPRESSION = False

DOWNSAMPLE = len(sys.argv) == 4 and sys.argv[3] == '-d'

in_file = open(sys.argv[1], "rb")
data = in_file.read()
in_file.close()

out_file = open(sys.argv[2], "wb")

def sgn(value):
	return -1 if value < 0 else 1 if value > 0 else 0

def signExtend(sample_byte):
	if sample_byte & 0x80:
		return sample_byte | (-1 ^ 0xFF)
	return sample_byte

def toUnsigned(sample_s):
	return (sample_s + 0x08) & 0x0F

def compressTo4Bit(sample_s):
	return sgn(sample_s) * int(math.floor(math.sqrt(2*abs(sample_s))/2))

it = iter(range(0, len(data)))
for i in it:
	if i < len(data) - 1:
		if COMPRESSION:
			smp1 = toUnsigned(compressTo4Bit(signExtend(ord(data[i]))))
			smp2 = toUnsigned(compressTo4Bit(signExtend(ord(data[i + 1]))))
		else:
			smp1 = ((ord(data[i]) + 0x80) >> 4) & 0x0F
			smp2 = ((ord(data[i + 1]) + 0x80) >> 4) & 0x0F
		smp1 ^= 0x0F
		smp2 ^= 0x0F
		out_file.write(chr(smp1 << 4 | smp2))
		next(it)
		if DOWNSAMPLE and i < len(data) - 2:
			next(it)
			if i < len(data) - 3:
				next(it)

out_file.close()
