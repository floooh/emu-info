.PHONY: all
%.bin : %.asm
	pasmo --amsdos $< $@

%.dsk: %.bin
	cpcxfs -f -nd $@
	cpcxfs $@ -f -p $<

%.cdt : %.bin
	2cdt -n $< $@

%.au : %.cdt
	playtzx $< -au

test_bin_o= cpu.bin \
	inout.bin \
	itest.bin \
	rtestopcodes.bin
	
test_cdt_o= cpu.cdt \
	inout.cdt \
	itest.cdt \
	rtestopcodes.cdt
	
test_au_o= cpu.au \
	inout.au \
	itest.au \
	rtestopcodes.au

all: test_bin test_cdt test_au
clean: 
	rm -f *.dsk
	rm -f *.bin
	rm -f *.cdt
	rm -f *.au
	rm -f *.cpr
  
test_bin: $(test_bin_o)
test_cdt: $(test_cdt_o)
test_au: $(test_au_o)
