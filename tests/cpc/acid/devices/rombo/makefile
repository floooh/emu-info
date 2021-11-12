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

test_asm = rombo

all:  test_bin test_cdt test_au


test_bin: $(addsuffix .bin,$(test_asm)) 
test_cdt: $(addsuffix .cdt,$(test_asm)) 
test_au: $(addsuffix .au,$(test_asm)) 

clean: 
	rm -f *.dsk
	rm -f *.bin
	rm -f *.cdt
	rm -f *.au
	rm -f *.cpr
  