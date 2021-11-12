These are snapshot files to be tested with an emulator and these test correct
behaviour (and information is correctly restored):

snapasic - sets up sprites (various positions and magnification), sprite palette, main palette, screen split, scroll (vertical, horizontal and enable border) and raster interrupt (single white bar in the upper 3rd of the screen). Then goes into a loop which tests if the asic ram is enabled or not and cart page 1 is selected in 0000-3fff and c000-ffff. Save snapshot and then load. If border shows stripes after loading snapshot then a0 configuration is not restored correctly. Check visually for sprites, palette, split and scroll. You should not see a vertical bar on the right, this is hidden by the scroll. You should not see the "HIDDEN" text because this is hidden by the split.

snaphalt - sets up  Z80 HALT with interrupts disabled. Snapshot should then be saved and then loaded. Border should remain grey. If border is not grey after loading snapshot then handling of HALT and/or Z80 interrupt enaled state when saving snapshot is not correct.

snapim - sets up IM 2. Snapshot should be saved and then loaded. Border should remain grey. If it is not then IM is not restored correctly.

snapdkram - 128KB required. Fills extra memory with data and selects C5 memory configuration and turns border grey. Snapshot should be saved and then loaded. Border should remain grey otherwise restoring ram configuration doesn't work.

In addition to these there are some example snapshots saved from various emulators in this directory. You can use that to ensure your emulator can load them.

winape_v1_64kb.sna -  Winape - V1 snapshot - 64KB RAM
winape_v1_128kb.sna - Winape - V1 snapshot - 128KB RAM 
winape_v2_64kb.sna - Winape - V2 snapshot - 64KB RAM
winape_v2_128kb.sna - Winape - V2 snapshot - 128KB RAM
winape_v3_64kb_uncompressed.sna - Winape - V3 snapshot - 64KB - uncompressed
winape_v3_64kb_compressed.sna - Winape - V3 snapshot - 64KB - compressed
winape_v3_128kb_uncompressed.sna - Winape - V3 snapshot - 128KB - uncompressed
winape_v3_128kb_compressed.sna - Winape - V3 snapshot - 128KB - compressed
winape_v3_256kb_uncompressed.sna - Winape - V3 snapshot - 256KB - uncompressed
winape_v3_256kb_compressed.sna - Winape - V3 snapshot - 256KB - compressed
winape_v3_512kb_uncompressed.sna - Winape - V3 snapshot - 512KB - uncompressed
winape_v3_512kb_compressed.sna - Winape - V3 snapshot - 512KB - compressed
winape_v3_silicon_disk_compressed.sna - Winape - V3 snapshot - 256KB silicon disk - uncompressed
winape_v3_silicon_disk_uncompressed.sna - Winape - V3 snapshot - 256KB silicon disk - compressed

nocpc_v3.sna - No$CPC - V3 snapshot - No Plus block.
nocpc_v3_plus.sna - No$CPC - V3 snapshot No Plus block.

javacpc_4mb.sna - JavaCPC -  V1 snapshot - 4MB
