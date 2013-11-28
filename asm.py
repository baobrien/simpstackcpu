#!/usr/bin/env python

# This is a simple assembler for the stack machine described by the verilog in this folder. 
# It implements an easy subset of prewritten instructions, but does not have a pnumeonic for
# every possible instruction of the stack machine. Almost every useful instruction can be achived
# by use of the modifyers which change the behaviour of the data stack, alu, and/or call stack.

#TODO: Modifiers would be nice.

# Instructions:
#
# nop -	 This is nop.
# add -	 1,2,3 > 1,5 - add - pop r0,r1. push r0+r1
# addc - 1,2,3 > 1,0,5 - add with carry - pop r0,r1. push carry,r0+r1
# sub -	 1,2,3 > 1,1 - subtract - pop r0,r1. push r0-r1.
# subc - 1,2,3 > 1,0,1 - subtract with overflow. pop r0,r1. push carry,r0-r1.
# and -	 1,2,3 > 1,2 - and - pop r0,r1. push r0&r1
# or -	 1,2,3 > 1,3 - or - pop r0,r1. push r0|r1
# xor -	 1,2,3 > 1,1 - xor - pop r0,r1. push r0^r1
# not -	 1,2,3 > 1,2,65532 - not - pop r0. push ~r0
# wr -	 1,2,0x1000 > 1,2 - write - pop r0. save new r0 into popped r0.  
# rd -	 1,0x1000 > 1,2 - read -Pop r0. Read address of r0. push contents of address.
# lit <literal value> - 1,2,3 > 1,2,3,4 - Push literal value onto stack
# shl - 1,2,2 > 1,8 - shift left - pop r0,r1. push r0<<r1.
# shr - 1,2,8 > 1,2 - shift right - pop r0,r1. push r0>>r1.
# dup 1,2,3 > 1,2,3,3 - duplicate - pop r0. push back onto stack twice
# del 1,2,3 > 1,2 - delete - pop r0
# swp 1,2,3 > 1,3,2 - swap
# bub <n> 0,1,2,3,4 > 0,2,3,4,1 - 'Bubble' a stack element from somewhere within the first eight elements to the top of the stack.
# rot 1,2,3,4 > 1,3,4,2 - rotate - rotate elements on top of stack
# inc 1,2,3 > 1,2,4 - increment - pop r0. increment r0. push r0.
# dec 1,2,3 > 1,2,2 - deincrement - pop r0. deincrement r0. push r0.
# pls - push loop start - Push value of IP to call stack. Keep executing
# call - 1,2,0x1000 > Push ip+1 onto call stack, jump to addr on top of data stack, pop from datastack
# ret - Jump to element on top of call stack, pop call stack
# dcm - 1,2,0x1000 > 1,2 - Pop top element of datastack, push to callstack
# cdm - 1,2 > 1,2,0x1000 - Pop top element of callstack, push to datastack
# jmp - 1,2,0x1000 > 1,2 - Jump to top of datastack, pop from datastack
# crt - 1,2,0 > 1,2 - Conditional Return - If top of datastack is not zero, jump to addr on top of callstack and pop it
# eq - 1,2,2 > 1,1 - Equal to - Pop r0 and r1. push top==next.
# gt - 1,2,3 > 1,1 - Greater than - Pop r0 and r1. push top>next.
# lt - 1,2,3 > 1,0 - Less than - Pop r0 and r1. push top<next.
# zero - 1,2,3 > 1,2,3,0 - Push 0.
# one - 1,2,3 > 1,2,3,1 - Push 1.
# dat 0	- Placeholder for data.
# str 'string' - Placeholder for zero-terminated string packed 2 chars per word
#
# Modifiers:
# 
# +r1 	- Stack mode replace 1
# +r2 	- stack mode replace 2
# +push - Stack mode push
# +pop	- Stack mode pop
# +rp 	- Stack mode pop and replace top
# +n	- No stack mode
#
# .<n>	- Select secondary stack cell
#
# ,<n>	- ALU Operator n
#
#
# Other:
# :label - This is a label
# @org <addr> - This is a start address
# ;comment - this can go at EOL

import re
import os
import sys

class instr:
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(0,0,0,0)
	
	def setdcodes(self,mainop,aluop,stkop,stksel):
		self.mainop=mainop
		self.aluop=aluop
		self.stksel=stksel
		self.stkop=stkop
	
	def setstackop(self,stackop):
		self.stkop = stackop
	
	def setstacksel(self,stacksel):
		self.stksel = stacksel
	
	def setaluop(self,aluope):
		self.aluop = aluope
	
	def geninsdat(self):
		insint = (self.mainop&0xf)|((self.aluop&0x1f)<<4)|((self.stkop&0x7)<<9)|((self.stksel&0x7f)<<12)
		self.insdat = hex(insint)[2:6]		
	
	def getnextaddr(self):			
		return self.lasti.getnextaddr()+1
	
	def getdata(self):
		self.geninsdat()
		return [self.insdat]
	
	def setparam(self,dat):
		return

class i_nop(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(0,0,0,0)

class i_add(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,2,5,1)

class i_addc(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,2,4,1)

class i_and(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,6,5,1)

class i_or(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,7,5,1)

class i_xor(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,9,5,1)

class i_not(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,8,4,1)

class i_sub(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,3,5,1)

class i_subc(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,3,4,1)

class i_wr(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(3,0,2,1)

class i_rd(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(2,0,3,1)

class i_shl(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,4,3,1)

class i_shr(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,5,3,1)

class i_del(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,0,2,1)

class i_dup(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,11,1,1)

class i_swp(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,10,4,1)

class i_bub(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,16,6,2)
	
	def setparam(self,param):
		pval = 0x7&int(eval(param))
		self.setstacksel(pval)

class i_rot(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,10,1,2)

class i_inc(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,17,3,1)

class i_dec(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(4,18,3,1)

class i_pls(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(10,0,0,1)

class i_call(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(7,0,2,1)

class i_ret(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(8,0,0,1)

class i_dcm(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(11,1,2,1)

class i_cdm(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(11,2,1,1)

class i_jmp(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(6,0,2,1)

class i_hlt(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(9,0,0,0)

class i_crt(instr):
	def __init__(self,lastinstr):
		self.lasti = lastinstr
		self.setdcodes(5,11,2,1)

class i_eq(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
		self.setdcodes(4,15,5,1)

class i_gt(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
		self.setdcodes(4,13,5,1)

class i_lt(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
		self.setdcodes(4,14,5,1)

class i_zero(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
		self.setdcodes(4,0,1,1)

class i_one(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
		self.setdcodes(4,1,1,1)

labellist = dict()

class i_lit(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
		self.setdcodes(1,0,1,1)
		self.parameter = ""
	
	def getnextaddr(self):
		return self.lasti.getnextaddr()+2
	
	def getdata(self):
		basedat = instr.getdata(self)
		if re.match(":.*",self.parameter): #is a label			
			na = labellist[self.parameter].getnextaddr()
			basedat.append(hex(na&0xFFFF)[2:])
		else: #just data
			basedat.append(hex(int(eval(self.parameter))&0xFFFF)[2:])
		return basedat
	
	def setparam(self,parameter):
		self.parameter = parameter

class m_label(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
	
	def getnextaddr(self):
		return self.lasti.getnextaddr()
	
	def setname(self,name):
		self.lblname = name
		labellist[name] = self
	
	def getdata(self):
		return []

class m_dat(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
	
	def getnextaddr(self):
		return self.lasti.getnextaddr()+1
	
	def setparam(self,parameter):
		self.parameter = parameter
	
	def getdata(self):
		return [hex(int(eval(self.parameter))&0xFFFF)[2:]]

class m_str(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
		self.data = []
	
	def getnextaddr(self):
		return self.lasti.getnextaddr()+len(data)
	
	def setparam(self,parameter):
		string = parameter + '\0'
		if len(string)&1 :
			string = string + '\0'
		hexstring = string.encode('hex')
		i = 0
		data = []
		print hexstring
		while i<(len(hexstring)):
			data = data + [hexstring[i:i+4]]
			i = i + 4
		self.data = data
		
	def getdata(self):
		return self.data


class m_org(instr):
	def __init__(self,lastinstr): 
		self.lasti = lastinstr
		self.orgaddr = 0
	
	def getdata(self):
		return ["@"+hex(self.orgaddr)[2:]] # Symbol for verilog hex file format
		
	def getnextaddr(self):
		return self.orgaddr
	
	def setparam(self,parameter):
		self.orgaddr = 0xFFFF&int(eval(parameter)) # Oh no it's a scary eval. 

opstrs = {
"add":i_add,
"addc":i_addc,
"nop":i_nop,
"sub":i_sub,
"subc":i_subc,
"and":i_and,
"or":i_or,
"xor":i_xor,
"not":i_not,
"wr":i_wr,
"rd":i_rd,
"lit":i_lit,
"shl":i_shl,
"shr":i_shr,
"dup":i_dup,
"del":i_del,
"rot":i_rot,
"inc":i_inc,
"dec":i_dec,
"pls":i_pls,
"call":i_call,
"ret":i_ret,
"dcm":i_dcm,
"cdm":i_cdm,
"swp":i_swp,
"jmp":i_jmp,
"crt":i_crt,
"retc":i_crt,
"eq":i_eq,
"gt":i_gt,
"lt":i_lt,
"zero":i_zero,
"one":i_one,
"@org":m_org,
"dat":m_dat,
"hlt":i_hlt,
"bub":i_bub
}

firstinst = m_org(0) # Serves as a zero-anchor
firstinst.setparam("0") # Set it to zero

if len(sys.argv)<3:
	print("Usage: "+sys.argv[0]+" in.s out.hex")
	sys.exit(1)

infile = file(sys.argv[1],"r+")
outfile = file(sys.argv[2],"w+")

labelregex = re.compile(":.*")

intext = infile.read()
infile.close
inlines = intext.split('\n')
curinst = firstinst
for line in inlines:
	op = line.split(';')[0] #Strip comment
	ops = []
	for opn in op.split(' '):
		ops = ops + opn.split('\t') #There's a better way to do this, but I'm tired
	
	opspl = [x.lower() for x in ops if x] #Fuckin' list comprehensions
	
	print opspl
	## Insert modifier separation stuff here
	if len(opspl)>0 : #Is instruction
		if re.match(":.*",opspl[0]):	#Is a label
			curinst = m_label(curinst)
			curinst.setname(opspl[0])
		elif opstrs.has_key(opspl[0]):	#could be another instruction
			curinst = opstrs[opspl[0]](curinst)
			if len(opspl)>1 :
				curinst.setparam(opspl[1])
		elif opspl[0]=='str' : #Strings have to be parsed differently
			curinst = m_str(curinst)
			spn = re.search('".*?"',line).span()
			if spn:
				curinst.setparam(line[spn[0]+1:spn[1]-1])
				print line[spn[0]:spn[1]]
			else:
				curinst.setparam("")
		else:
			print "Did not recognize op "+str(opspl)

output = []
while curinst != firstinst:
	output = curinst.getdata() + output
	curinst = curinst.lasti
	
for line in output:
	print line
	outfile.write(line+"\n")





# 22 54 68 69  73  20 69  73  20  61  20 73 74 72 69 6e 67220000











