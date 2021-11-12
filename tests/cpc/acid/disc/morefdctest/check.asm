checkdrv:

;; load head, wait for head settling time and then reads ids
;; start to read sector,
;; read crc and then give result... so result happens approx 64 us after reading crc from sector
;; after read data command is done, head is not unloaded until head unload time interval has elapsed.
;; 27 microseconds in FM mode every 13 microseconds in MFM mode.
;; write: 31 microseconds or 15 microseconds

;; execution bit high during seek/recalibrate?
;; fdc busy?
;; exeuction but during read/write

;; specify
;; srt = step rate (16ms, 32ms, 240ms) -> 32ms, 64ms etc.
;; millisecond = 1/1000 (approx 1000 NOPs per step)
;; hut = head unload time (16, 32, etc ms) 
;; hlt = head load time (1, 16 ms) (4ms, 8ms, 12ms ...)
;;
;; default:
;; 03,a1,03
;; srt = 0x0a f = 2ms, e = 4ms, d=6ms, c=8ms,b=10ms,a=12ms
;; head unload time = 0x01 = 32ms
;; head load time = 0x01  = 4ms



;; seek
;; parallel seeks -> not ready/ready
;; this only indicates if disc is not in drive.
;; not that drive exists.

;; sense interrupt status can be used to detect if disc has been inserted?

;; 6,000,000 us in a second
;; 300rpm 
;; 200000 us per rotation
;;  19968 us per frame
;; approx 10 frames per rotation
;; approx 333.33 us per revolution
;; 15000rps
;; 196608us approx 199680 us per rotation
;; 6240 bytes?
;; 6250 bytes approx

;; test:
;; 1. head load time
;; 2. head unload time
;; 3. time between command and execution phase bit changing
;; 4. does load time happen after step?
;; 5. step timing
;; 6. does execution end on last byte being read.. or after crc.. or later?

;; gap4a: 
;; 80x 4e
;; 12 bytes &00 (fixed)
;; 3 bytes &c2 (fixed)
;; 1 byte index mark
;; 50 bytes 4e (gap 1)

;; for each sector:
;; 12 bytes $00 (fixed)
;; 3 bytes &a1 (fixed)
;; 1 byte id mark (fixed)
;; 1 byte c
;; 1 byte h
;; 1 byte r
;; 1 byte n
;; 2 byte crc (low-high)
;; 22 bytes &4e (gap 2 fixed)
;; 12 bytes &00 (fixed)
;; 3 bytes &a1 (fixed)
;; 1 byte data mark (fixed)
;; n bytes data field
;; 2 bytes crc (low-high)
;; n bytes 4e (gap3)

;; n bytes 4e gap4b

;; 62 bytes per sector
;;
;; 512 + 62 = 574 bytes
;; 574 * 32 = 18368us per sector
;; 19968-18368 = 1600us
;; 1600/32 = 50 bytes (&32)
;;
;; 256 + 62 = 318 bytes
;; 318 * 32 = 10176us per sector
;; 19968-10176 = 9792us
;; 9792/32 = 306 bytes 
;;
;; 5625 for 9 sectors (5771) (146 bytes)
;; 479 bytes gap 4

;; drive B led on, drive A led off
;; drive A report missing even when disc in drive but no disc in drive B
;; !!! specify not reset when fdc reset. only when power off!!!!

;; 21f b5a b53 a31e
;;
;; 152 bytes 
;; 136 bytes 90 + 46
