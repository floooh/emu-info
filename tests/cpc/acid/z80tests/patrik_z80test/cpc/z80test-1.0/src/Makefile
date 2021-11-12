# gmake

NAME = z80test
VERSION = 1.0
PKG := $(NAME)-$(VERSION)

PROGS := z80full z80flags z80doc z80docflags z80ccf z80memptr
SRCS  := main tests testmacros print idea crctab 

all: $(addsuffix .dsk,$(PROGS)) $(addsuffix .cdt,$(PROGS))

.DELETE_ON_ERROR: %.out

%.bin : %.out
	mv $< data.bin
	pasmo --amsdos cpc.asm $@

%.out : %.asm $(addsuffix .asm,$(SRCS))
	sjasm $<

%.dsk : %.bin
	cpcxfs -f -nd $@
	cpcxfs $@ -f -p $<

%.cdt : %.bin
	2cdt -n $< $@

FILES := Makefile loader.bas $(addsuffix .asm,$(PROGS)) $(addsuffix .asm, $(SRCS))

dist: all
	ln -s .. $(PKG)
	cp *.dsk $(PKG)
	zip ../$(PKG).zip $(addprefix $(PKG)/src/, $(FILES)) $(PKG)/*.txt $(PKG)/*.dsk $(PKG)/*.cdt
	rm $(PKG)/*.dsk
	rm $(PKG)

clean:
	rm -rf *.out *.lst *.dsk *.cdt

tidy: clean
	rm -rf $(PROGS)
