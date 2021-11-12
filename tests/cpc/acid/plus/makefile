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

test_asm = asicfloat \
	asiclock \
	asicppi \
	asicraster \
	asicrom \
	asictest \
	asic_after_lock \
	lumasic \
	lumasic2 \
	asic_external_ram \
	dmatest \
	dmatiming \
	hscrl \
	hscrl0 \
	hscrl0b \
	hscrl1 \
	hscrl1b \
	hscrl_mid \
	onlyin \
	pluscol \
	pluscols \
	pluspen \
	plus_standard_hlace \
	pritest \
	pritrig \
	pri_ack_cpc_int \
	pri_delay_cpc_int \
	pri_hsync_pos \
	pri_hsync_width \
	pri_mix \
	pri_mix2 \
	pri_mix_no_change \
	scrlr8 \
	scrl_mid \
	split1 \
	split3d \
	splitmask \
	splits \
	splits2 \
	splits3 \
	splittrig \
	splittrig2 \
	splittrig3 \
	splittrig3b \
	splittrig3c \
	splittrig4 \
	splt \
	splt2 \
	splt3 \
	splt3b \
	splt3c \
	spltr8 \
	spr_mag_mirror \
	vscrl \
	vscrl2 \
	vscrl2c \
	vscrl_2b \
	vscrl_hdisp \
	vscrl_r9 \
	vscrl_r9_16 \
	vscrl_r9_4 \
	vscroll_r9_31_ok \
	dmatiming2

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
  