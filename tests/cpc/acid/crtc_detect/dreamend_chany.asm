; Start &9f00
; End &a1a4
; Length: &02a4
9F00:           DI
9F01:           LD HL,(#0038)
9F04:           LD (#9F46),HL
9F07:           LD HL,#C9FB
9F0A:           LD (#0038),HL
9F0D:           LD HL,#9FDC
9F10:           LD BC,#BD0C
9F13:           OUTI
9F15:           INC B
9F16:           INC B
9F17:           OUTI
9F19:           DEC C
9F1A:           JR NZ,#9F13
9F1C:           CALL #9F5C
9F1F:           LD E,A
9F20:           LD D,#00
9F22:           CP A,#02
9F24:           JP Z,#9F3A
9F27:           CP A,#01
9F29:           JP NZ,#9F32
9F2C:           CALL #9FF4
9F2F:           JP #9F3A
9F32:           LD A,#06
9F34:           LD (#A015),A
9F37:           CALL #9FF4
9F3A:           LD BC,#BC06
9F3D:           OUT (C),C
9F3F:           LD BC,#BD19
9F42:           OUT (C),C
9F44:           DI
9F45:           LD HL,#41C3
9F48:           LD (#0038),HL
9F4B:           EI
9F4C:           LD A,D
9F4D:           CP A,#FF
9F4F:           JP Z,#9F58
9F52:           LD A,E
9F53:           CP A,#01
9F55:           RET Z
9F56:           NOP
9F57:           NOP
9F58:           JP #7000
9F5B:           RET
9F5C:           LD HL,#A200
9F5F:           LD (HL),#A0
9F61:           INC HL
9F62:           LD (HL),#A1
9F64:           LD E,L
9F65:           LD D,H
9F66:           INC DE
9F67:           DEC HL
9F68:           LD BC,#00FF
9F6B:           LDIR
9F6D:           LD A,#A2
9F6F:           LD I,A
9F71:           IM 2
9F73:           EI
9F74:           HALT
9F75:           DI
9F76:           IM 1
9F78:           OR A,A
9F79:           RET NZ
9F7A:           LD B,#F5
9F7C:           IN A,(C)
9F7E:           RRA
9F7F:           JR NC,#9F7C
9F81:           IN A,(C)
9F83:           RRA
9F84:           JR C,#9F81
9F86:           IN A,(C)
9F88:           RRA
9F89:           JR NC,#9F86
9F8B:           EI
9F8C:           HALT
9F8D:           LD HL,#004B
9F90:           DEC HL
9F91:           LD A,H
9F92:           OR A,L
9F93:           JR NZ,#9F90
9F95:           IN A,(C)
9F97:           RRA
9F98:           JR C,#9FAF
9F9A:           LD BC,#BC0C
9F9D:           OUT (C),C
9F9F:           LD A,#29
9FA1:           INC B
9FA2:           OUT (C),E
9FA4:           INC B
9FA5:           IN A,(C)
9FA7:           CP A,E
9FA8:           JR NZ,#9FAD
9FAA:           LD A,#04
9FAC:           RET
9FAD:           XOR A,A
9FAE:           RET
9FAF:           HALT
9FB0:           HALT
9FB1:           HALT
9FB2:           DI
9FB3:           IN A,(C)
9FB5:           RRA
9FB6:           JR NC,#9FB3
9FB8:           LD BC,#BC02
9FBB:           OUT (C),C
9FBD:           LD BC,#BD32
9FC0:           OUT (C),C
9FC2:           EI
9FC3:           HALT
9FC4:           HALT
9FC5:           HALT
9FC6:           HALT
9FC7:           HALT
9FC8:           HALT
9FC9:           HALT
9FCA:           LD B,#F5
9FCC:           IN A,(C)
9FCE:           RRA
9FCF:           LD BC,#BD2E
9FD2:           OUT (C),C
9FD4:           JR NC,#9FD9
9FD6:           LD A,#01
9FD8:           RET
9FD9:           LD A,#02
9FDB:           RET
9FDC:           NOP
9FDD:           CCF
9FDE:           LD BC,#0228
9FE1:           LD L,#03
9FE3:           ADC A,(HL)
9FE4:           INC B
9FE5:           LD H,#05
9FE7:           NOP
9FE8:           LD B,#00
9FEA:           RLCA
9FEB:           LD E,#08
9FED:           NOP
9FEE:           ADD HL,BC
9FEF:           RLCA
9FF0:           INC C
9FF1:           JR NC,#A000
9FF3:           NOP
9FF4:           LD B,#F5
9FF6:           IN A,(C)
9FF8:           RRA
9FF9:           JR NC,#9FF6
9FFB:           IN A,(C)
9FFD:           RRA
9FFE:           JR C,#9FFB
A000:           HALT
A001:           HALT
A002:           HALT
A003:           HALT
A004:           HALT
A005:           LD BC,#BC08
A008:           OUT (C),C
A00A:           LD BC,#BD03
A00D:           OUT (C),C
A00F:           LD BC,#BC09
A012:           OUT (C),C
A014:           LD BC,#BD07
A017:           OUT (C),C
A019:           LD B,#F5
A01B:           IN A,(C)
A01D:           RRA
A01E:           JR NC,#A01B
A020:           IN A,(C)
A022:           RRA
A023:           JR C,#A020
A025:           HALT
A026:           HALT
A027:           HALT
A028:           LD D,#FF
A02A:           IN A,(C)
A02C:           RRA
A02D:           JR NC,#A031
A02F:           LD D,#00
A031:           LD BC,#BC08
A034:           OUT (C),C
A036:           LD BC,#BD00
A039:           OUT (C),C
A03B:           LD BC,#BC09
A03E:           OUT (C),C
A040:           LD BC,#BD07
A043:           OUT (C),C
A045:           RET
A046:           NOP
A047:           NOP
A048:           NOP
A049:           NOP
A04A:           NOP
A04B:           NOP
A04C:           NOP
A04D:           NOP
A04E:           NOP
A04F:           NOP
A050:           NOP
A051:           NOP
A052:           NOP
A053:           NOP
A054:           NOP
A055:           NOP
A056:           NOP
A057:           NOP
A058:           NOP
A059:           NOP
A05A:           NOP
A05B:           NOP
A05C:           NOP
A05D:           NOP
A05E:           NOP
A05F:           NOP
A060:           NOP
A061:           NOP
A062:           NOP
A063:           NOP
A064:           NOP
A065:           NOP
A066:           NOP
A067:           NOP
A068:           NOP
A069:           NOP
A06A:           NOP
A06B:           NOP
A06C:           NOP
A06D:           NOP
A06E:           NOP
A06F:           NOP
A070:           NOP
A071:           NOP
A072:           NOP
A073:           NOP
A074:           NOP
A075:           NOP
A076:           NOP
A077:           NOP
A078:           NOP
A079:           NOP
A07A:           NOP
A07B:           NOP
A07C:           NOP
A07D:           NOP
A07E:           NOP
A07F:           NOP
A080:           NOP
A081:           NOP
A082:           NOP
A083:           NOP
A084:           NOP
A085:           NOP
A086:           NOP
A087:           NOP
A088:           NOP
A089:           NOP
A08A:           NOP
A08B:           NOP
A08C:           NOP
A08D:           NOP
A08E:           NOP
A08F:           NOP
A090:           NOP
A091:           NOP
A092:           NOP
A093:           NOP
A094:           NOP
A095:           NOP
A096:           NOP
A097:           NOP
A098:           NOP
A099:           NOP
A09A:           NOP
A09B:           NOP
A09C:           NOP
A09D:           NOP
A09E:           NOP
A09F:           NOP
A0A0:           NOP
A0A1:           XOR A,A
A0A2:           EI
A0A3:           RET
A0A4:           NOP
A0A5:           NOP
A0A6:           NOP
A0A7:           NOP
A0A8:           NOP
A0A9:           NOP
A0AA:           NOP
A0AB:           NOP
A0AC:           NOP
A0AD:           NOP
A0AE:           NOP
A0AF:           NOP
A0B0:           NOP
A0B1:           NOP
A0B2:           NOP
A0B3:           NOP
A0B4:           NOP
A0B5:           NOP
A0B6:           NOP
A0B7:           NOP
A0B8:           NOP
A0B9:           NOP
A0BA:           NOP
A0BB:           NOP
A0BC:           NOP
A0BD:           NOP
A0BE:           NOP
A0BF:           NOP
A0C0:           NOP
A0C1:           NOP
A0C2:           NOP
A0C3:           NOP
A0C4:           NOP
A0C5:           NOP
A0C6:           NOP
A0C7:           NOP
A0C8:           NOP
A0C9:           NOP
A0CA:           NOP
A0CB:           NOP
A0CC:           NOP
A0CD:           NOP
A0CE:           NOP
A0CF:           NOP
A0D0:           NOP
A0D1:           NOP
A0D2:           NOP
A0D3:           NOP
A0D4:           NOP
A0D5:           NOP
A0D6:           NOP
A0D7:           NOP
A0D8:           NOP
A0D9:           NOP
A0DA:           NOP
A0DB:           NOP
A0DC:           NOP
A0DD:           NOP
A0DE:           NOP
A0DF:           NOP
A0E0:           NOP
A0E1:           NOP
A0E2:           NOP
A0E3:           NOP
A0E4:           NOP
A0E5:           NOP
A0E6:           NOP
A0E7:           NOP
A0E8:           NOP
A0E9:           NOP
A0EA:           NOP
A0EB:           NOP
A0EC:           NOP
A0ED:           NOP
A0EE:           NOP
A0EF:           NOP
A0F0:           NOP
A0F1:           NOP
A0F2:           NOP
A0F3:           NOP
A0F4:           NOP
A0F5:           NOP
A0F6:           NOP
A0F7:           NOP
A0F8:           NOP
A0F9:           NOP
A0FA:           NOP
A0FB:           NOP
A0FC:           NOP
A0FD:           NOP
A0FE:           NOP
A0FF:           NOP
A100:           NOP
A101:           NOP
A102:           NOP
A103:           NOP
A104:           NOP
A105:           NOP
A106:           NOP
A107:           NOP
A108:           NOP
A109:           NOP
A10A:           NOP
A10B:           NOP
A10C:           NOP
A10D:           NOP
A10E:           NOP
A10F:           NOP
A110:           NOP
A111:           NOP
A112:           NOP
A113:           NOP
A114:           NOP
A115:           NOP
A116:           NOP
A117:           NOP
A118:           NOP
A119:           NOP
A11A:           NOP
A11B:           NOP
A11C:           NOP
A11D:           NOP
A11E:           NOP
A11F:           NOP
A120:           NOP
A121:           NOP
A122:           NOP
A123:           NOP
A124:           NOP
A125:           NOP
A126:           NOP
A127:           NOP
A128:           NOP
A129:           NOP
A12A:           NOP
A12B:           NOP
A12C:           NOP
A12D:           NOP
A12E:           NOP
A12F:           NOP
A130:           NOP
A131:           NOP
A132:           NOP
A133:           NOP
A134:           NOP
A135:           NOP
A136:           NOP
A137:           NOP
A138:           NOP
A139:           NOP
A13A:           NOP
A13B:           NOP
A13C:           NOP
A13D:           NOP
A13E:           NOP
A13F:           NOP
A140:           NOP
A141:           NOP
A142:           NOP
A143:           NOP
A144:           NOP
A145:           NOP
A146:           NOP
A147:           NOP
A148:           NOP
A149:           NOP
A14A:           NOP
A14B:           NOP
A14C:           NOP
A14D:           NOP
A14E:           NOP
A14F:           NOP
A150:           NOP
A151:           NOP
A152:           NOP
A153:           NOP
A154:           NOP
A155:           NOP
A156:           NOP
A157:           NOP
A158:           NOP
A159:           NOP
A15A:           NOP
A15B:           NOP
A15C:           NOP
A15D:           NOP
A15E:           NOP
A15F:           NOP
A160:           NOP
A161:           NOP
A162:           NOP
A163:           NOP
A164:           NOP
A165:           NOP
A166:           NOP
A167:           NOP
A168:           NOP
A169:           NOP
A16A:           NOP
A16B:           NOP
A16C:           NOP
A16D:           NOP
A16E:           NOP
A16F:           NOP
A170:           NOP
A171:           NOP
A172:           NOP
A173:           NOP
A174:           NOP
A175:           NOP
A176:           NOP
A177:           NOP
A178:           NOP
A179:           NOP
A17A:           NOP
A17B:           NOP
A17C:           NOP
A17D:           NOP
A17E:           NOP
A17F:           NOP
A180:           NOP
A181:           NOP
A182:           NOP
A183:           NOP
A184:           NOP
A185:           NOP
A186:           NOP
A187:           NOP
A188:           NOP
A189:           NOP
A18A:           NOP
A18B:           NOP
A18C:           NOP
A18D:           NOP
A18E:           NOP
A18F:           NOP
A190:           NOP
A191:           NOP
A192:           NOP
A193:           NOP
A194:           NOP
A195:           NOP
A196:           NOP
A197:           NOP
A198:           NOP
A199:           NOP
A19A:           NOP
A19B:           NOP
A19C:           NOP
A19D:           NOP
A19E:           NOP
A19F:           NOP
A1A0:           LD A,#03
A1A2:           EI
A1A3:           RET
A1A4:           NOP
