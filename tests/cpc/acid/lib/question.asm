
yes_no_message:
call output_msg
ynagain:
call &bb06
ld c,1
cp 'y'
jr z,yndone
cp 'Y'
jr z,yndone
ld c,0
cp 'n'
jr z,yndone
cp 'N'
jr z,yndone
jr ynagain
yndone:
push bc
ld a,c
or a
ld a,'N'
jr z,yndone2
ld a,'Y'
yndone2:
call output_char
ld a,13
call output_char
pop bc
ld a,c
ret
