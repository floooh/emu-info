
.vs_time
;; sync with start of vsync

call vsync_sync

;; check vsync each line.
;; if active, increment counter,
;; otherwise quit.

ld e,0          ;; line counter
.v2
ld b,&f5        ;; [2]
in a,(c)        ;; [4]
rra             ;; [1]
jp nc,v3        ;; [3]
inc e           ;; [1]
defs 64-2-4-1-3-1-3
jp v2          ;; [3]


.v3
ld a,e
ret
