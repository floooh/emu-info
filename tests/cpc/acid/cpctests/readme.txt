Copyright (c) 2015 Kevin Thacker (aka arnoldemu)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

NOTE: All tests have been run on REAL hardware and 
PASS on real hardware.

Plus testing has mainly been done on a GX4000.
I used a C4CPC device made by gerald. This device
allows you to put cartridge images onto a micro SD
card and then run them on GX4000, 464Plus and 6128Plus.

Find him on the cpcwiki and get one!

I used nocart tool to put a disc image into a
cartridge.

For CPC testing I use audacity and a tape cable
to play the sound into the CPC.

For CPC464 I used a fake tape. On 6128 and 664
I used my own cable.

Running on arnold:
- Choose the appropiate computer configuration (Plus, CPC etc)
- You can autostart the binary files directly

* inicron.asm - Test RAM paging and I/O port decoding of Inicron 512KB ram expansion. Test incomplete. Not visual.

* crtc_r1.asm - Set various R1 values and shows the result. Visual test.

* crtc_r1_2.asm - Uses R1 to hide graphics and shows the result. Visual test.

* crtc_r5.asm - Setup R5 to add extra lines, shows how CRTC displays graphics during this time. Visual test.

* dispskewp.asm - R8 all DISPTMG delay values + Plus hide left border for scroll. Visual test.

* dispskew.asm - R8 all DISPTMG delay values. Type 0,3 and 4 only. Visual test.

* crtc3_4_status.asm - Tests CRTC type 3 and 4 status registers. Not visual.

* inout.asm - Test flags for IN instructions. Not visual.

* sym2.asm - Symbiface 2 tester. Currently tests ram and rom and limited RTC testing. Not visual.

* yarek4mb.asm - Test ram configuration and I/O port decoding of Yarek's 4MB internal ram expansion. Not visual.

* vortex.asm -  Test Vortex 512KB Internal RAM expansion hardware. Not visual.

* splits.asm - Test ASIC split screen. Visual test.

* splits2.asm - More testing of ASIC split screen. Visual test.

* splits3.asm - More testing of ASIC split screen. Visual test.

* asicraster.asm - Shows that if you write a 16-bit value to plus palette registers you can see 1 us of transition colour. Colour is not 
immediately changed. Below this is colour set using CPC method which is immediate. Visual test.

* asic_external_ram.asm - Tests write through to ram when writing to mapped in asic registers. 
Test with: 464Plus (no extra ram), 6128Plus (extra 64kb internal), 464Plus with external ram expansion (e.g. x-mem),
6128Plus (with external ram e.g. x-mem). Not visual.

* intsync.asm - Turns on Interlace and Sync mode on CRTC. Works on type 1 only. Visual test. Shows two images, both should 
appear correctly with no corruption.

* ramcheck.asm - Check 64kb ram expansion configurations work as expected. tests c0-c7. Not visual.
Also checks external 64kb ram expansion on 464 and how the ROM is moved in C3 configuration.

* crtctest.asm - Tests some aspects of CRTC. Not-visual tests. 

* asicfloat.asm - Test areas of ASIC ram that are unmapped for read and write, or read. Plus only. Non-visual test.

* hscrl0.asm - Test asic horizontal scroll, all possible values, all pens for mode 0. You should see some artifacts around some letters. Paper is 0.

* hscrl1asm - Test asic horizontal scroll, all possible values, all pens for mode 1. You should see some artifacts around some letters. Paper is 0.

* scrl_mid.asm - Horizontal and vertical scroll mid screen. You should not see any colour change, pixels should move smoothly. Vertical scroll will not be perfect, but will scroll. Enables and then disables scrolling mid-line. Visual test.

* ppi.asm - Test 8255 PPI in CPC. Doesn't work on Plus. Non-visual test.

* ppi_audio.asm - Writing to PPI can make audio. CPC only because of it's built in speaker. Doesn't work on Plus. Audio test.

* vscrl_hdisp.asm - Shows SSCR read at HDISP time in order to trigger screen address update for scroll. You should see 1 line of 07, but then 7 lines of 08. Visual test.

* vscrl_r9_31_ok.asm - Shows using scroll when R9=31 works fine. Visual test. No strangeness that can be seen when R9<7.

* pri_ack_cpc_int.asm - Mixing PRI and CPC ints. Shows when PRI is acknowledged, CPC int can be delayed. Visual test.

* pri_delay_cpc_int.asm - Mixing PRI and CPC ints. Shows when raster counter reset is used it will delay CPC ints. Visual test.

* pri_hsync_width.asm - Shows that the position of the PRI interrupt is not effected by HSYNC width and therefore it is based off the start of the HSYNC.
Visual test.

* dmatiming.asm - Uses dma interrupts to show exection of dma instructions (e.g. order). Visual test.
A raster bar is displayed to show where the int occurred. Read the asm to find accurate positions read from gx4000.
Arnold's timing is not perfect here.

* cpctest.asm - Test CPC (currently rom selection with bit5=0 and bit 5=1), Not visual.

* cpcborder.asm - select border (with bit5=0 and bit5=1), should see alternating black and white lines of 2 pixels thickness. Visual test.

* cpccol.asm - GA function &40, setting colours with bit5=0 and bit5=1 to show it's ignored. There should be two separate blocks which have the same colour in them. Visual test.

* cpcpen.asm - GA function &00, setting pen with bit5=0 and bit5=1. Should see two static bars of yellow between the grey. Visual test.

* colours.asm - Shows all CPC colours including "invalid" ones. Visual test

* hblank.asm - Shows horizontal blanking and HSYNC width to monitor. HSYNC will be black, blanking will be almost black depending on monitor brightness. Programs different hsync widths.
Blanking happens for the whole of the hsync output from the CRTC. HSYNC starts 2 cycles after the start of HSYNC and lasts for 4 cycles (if HSYNC>6). Blanking visible as a vertical column in the centre of the screen. Visual test.

* vblank.asm - Shows vertical blanking and VSYNC to monitor. VSYNC will be black, and almost invisible on most monitors, blanking will be almost black depending on monitro brightness. You will see
26 lines of blanking. 2 lines of blanking followed by 4 lines of VSYNC to monitor. Visual test.

* cpu.asm - Test some Z80 CPU things (NMOS tests)

* rtestopcodes.asm - Test R register increment. Not visual. For IM0 test runs ok on CPC.

* psg.asm - Test AY-3-8912 in combination with PPI. Not visual.

* psgexer.asm - Test AY-3-8912. Audio test. Exercises PSG registers. 

* type1ctrl.asm - Test CRTC type 1 status register. Must be run after power on/off.
Not visual.

* crtc1_r6.asm - Test R6=0 showing border on CRTC type 1. Doesn't do 
anything on type 0,2,3 or 4. crtc_r1.png shows result. Visual test.

* crtc0_3_4_r8.asm - Test R8 delay showing border for CRTC type 0,3,4 only. 
Doesn't do anything on 0 or 2. crtc_r8.png shows result. Visual test.

* onlyin.asm - Uses IN instructions only to show a raster bar. Works on Plus. Doesn't work on CPCs. Doesn't work on type 4.
Visual test.

* onlyincpc.asm - Uses IN instructions only to show a raster bar. Works on CPC and Plus.  Visual test.

* onlyincrtc.asm - Uses IN instructions only to change displayed length on CRTC. Works on CPC and Plus. Visual test.

* dispskew.asm - Uses DISPTMG skew. Cycles through them. Screen is skewed 0 chars, 1 char, 2 chars or border is drawn. Type 0,3 and 4 only.
Visual test.

* asictest.asm - tests cpc compatibility on asic and asic registers. Not visual.
Arnold fails on PRI bugs and in relation to HSYNC width and length.

* crtcinp.asm - tests IN writing to CRTC on CPC. CPC test. Visual test. Shows a single bar of 8 lines tall.
With two lines of repeated text.

* vsyncout.asm - set PPI port B to output and force VSYNC state. Visual test. Works on type 0, but not 1 or 2. A black bar should be visible in the middle of the screen.

* lumfirm.asm - Run on an Amstrad monochrome monitor. Sets colours. Brightness increases. Press space to go to next brightness. Visual test.

* asicppi.asm - Tests ASIC "PPI" emulation. Plus only. Not visual.

* asic_after_lock.asm - Unlocking plus hardware, setting it up and locking plus hardware again. Screen split, sprites and palette are tested. All should continue to operate. Plus only. Visual test.

* asiclock.asm - Test asic locking/unlocking sequence. Plus only. Not visual.

* spr_mag_mirror.asm - Test sprite magnification can be accessed through +4,+5,+6 and +7. Plus only. Visual test. Should show 4 sprites.

* asicrom.asm - Test ASIC RMR2 register. Checks rom/register page configurations, lower rom selection using rmr2 and write through from rom to ram when paged in. Not visual.
Arnold currently fails on the first test showing b0 instead of 50 for one byte. Arnold's emulation of the unmapped area is incomplete here.

* dmatest.asm - Test ASIC Audio DMA. Arnold fails on dma int request test because of instruction execution timing
and crtc r0 length. Non visual test.

* vscrl.asm - Test ASIC Vertical SSCR. Horizontal SSCR partially tested. R9=7 mixed with R9=3 and R9=15. (R9==7). Visual test.

* vscrl_r9.asm - Test R9=0..15 with ASIC Vertical SSCR.  Visual test.

* vscrl_r9_4.asm - Test ASIC Vertical SSCR. Horizontal SSCR partially tested. R9=3 only. (R9<7) Visual test.

* vscrl_r9_16.asm - Test ASIC Vertical SSCR. Horizontal SSCR partially tested. R9=15 only. (R9>7) Visual test.
