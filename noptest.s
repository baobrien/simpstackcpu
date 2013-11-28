nop		;Safety nop sled
nop
nop

one		;counter initalization
pls		;Start of outer loupe

lit 0x1000	;Push countdown
pls
dec		;Decrement counter
dup
retc
del

inc
lit 0x1000	;Push address for output
wr

ret		;Return to outer loop start
