#!/usr/bin/env python
import sys
import re

if len(sys.argv)<3:
	print "This converts verilog .hex files into Xillinx .coe"
	print "Usage: "+sys.argv[0]+" in.hex out.coe"
	sys.exit()
infile = file(sys.argv[1],"r+")
outfile = file(sys.argv[2],"w+")

outfile.write("memory_initialization_radix=16;\n");
outfile.write("memory_initialization_vector=\n");

mem_array = []
lines = infile.read().split('\n')
infile.close()
curptr = 0
for line in lines:
	
	if re.search("\@[0-9A-Fa-f]+",line): #is address to do stuff
		spn = re.search("\@[0-9A-Fa-f]+",line).span()
		datstr = line[spn[0]+1:spn[1]]
		curptr = int(eval('0x'+datstr))
	elif re.search("[0-9A-Fa-f]+",line): #is just data
		spn = re.search("[0-9A-Fa-f]+",line).span()
		datstr = line[spn[0]:spn[1]]
		print datstr
		data = int(eval('0x'+datstr))
		if len(mem_array)<=curptr:
			while len(mem_array)<=curptr:
				mem_array.append(0)
		mem_array[curptr]=data
		curptr = curptr + 1

for elem in mem_array:
	outfile.write(hex(elem)[2:]+",\n")
outfile.write(";\n")
outfile.flush()
outfile.close()
