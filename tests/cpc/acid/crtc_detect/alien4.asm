; Start &1b9f
; End &1bf5
; Length: &0056
1B9F:           LD B,#F5
1BA1:           IN A,(C)
1BA3:           RRA
1BA4:           JP NC,#1BA1
1BA7:           IN A,(C)
1BA9:           RRA
1BAA:           JP NC,#1BA7
1BAD:           EI
1BAE:           HALT
1BAF:           LD HL,#004B
1BB2:           DEC HL
1BB3:           LD A,H
1BB4:           OR A,L
1BB5:           JP NZ,#1BB2
1BB8:           IN A,(C)
1BBA:           RRA
1BBB:           JP C,#1BC2
1BBE:           XOR A,A
1BBF:           JP #1BE9
1BC2:           HALT
1BC3:           HALT
1BC4:           DI
1BC5:           IN A,(C)
1BC7:           RRA
1BC8:           JP NC,#1BC5
1BCB:           LD BC,#BC02
1BCE:           OUT (C),C
1BD0:           LD BC,#BD32
1BD3:           OUT (C),C
1BD5:           EI
1BD6:           HALT
1BD7:           HALT
1BD8:           HALT
1BD9:           HALT
1BDA:           HALT
1BDB:           HALT
1BDC:           HALT
1BDD:           LD B,#F5
1BDF:           IN A,(C)
1BE1:           RRA
1BE2:           LD A,#02
1BE4:           JP NC,#1BE9
1BE7:           LD A,#01
1BE9:           LD BC,#BC02
1BEC:           OUT (C),C
1BEE:           LD BC,#BD2E
1BF1:           OUT (C),C
1BF3:           ADD A,#30
1BF5:           LD (#1827),A
