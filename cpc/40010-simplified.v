//
// Amstrad CPC 40010 Gate Array implementation in Verilog.
//
// Ash Evans. 2016
//
//
// Translated from the superb PDF schematic by Gerald, which he dechipered from a decapped 40010 chip...
//
// http://www.cpcwiki.eu/forum/amstrad-cpc-hardware/gate-array-decapped!/msg133284/#msg133284
//


// PDF page 1...
module ga_400010 (
	input PAD_RESET_N,
	input PAD_MREQ_N,
	input PAD_M1_N,
	input PAD_RD_N,
	input PAD_IORQ_N,
	input PAD_16MHZ,
	input PAD_HSYNC,
	input PAD_VSYNC,
	input PAD_DISPEN,
	input PAD_A15,
	input PAD_A14,
	input [7:0] PAD_D,
	
	output PAD_RAS_N,
	output PAD_READY,
	output PAD_CASAD_N,
	output PAD_CPU_N,		// Should be _N on PDF page 1 as well?
	output PAD_MWE_N,
	output PAD_244E_N,
	output PAD_CCLK,
	output PAD_PHI_N,
	
	output PAD_CAS_N,
	
	output PAD_SYNC_N,
	output PAD_INT_N,
	
	output PAD_RED,
	output PAD_GREEN,
	output PAD_BLUE,
	
	output PAD_ROMEN_N,
	output PAD_RAMRD_N
);


wire U121 = !PAD_RESET_N;
wire CLK_16M_N = !PAD_16MHZ;	// U120.

wire S0, S1, S2, S3, S4, S5, S6, S7;
sequencer sequencer_inst
(
	.RESET(U121) ,	// input  RESET
	.M1_N(PAD_M1_N) ,	// input  M1_N
	.IORQ_N(PAD_IORQ_N) ,	// input  IORQ_N
	.RD_N(PAD_RD_N) ,	// input  RD_N
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.S0(S0) ,	// output  S0
	.S1(S1) ,	// output  S1
	.S2(S2) ,	// output  S2
	.S3(S3) ,	// output  S3
	.S4(S4) ,	// output  S4
	.S5(S5) ,	// output  S5
	.S6(S6) ,	// output  S6
	.S7(S7) 	// output  S7
);

sequence_decoder sequence_decoder_inst
(
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.S0(S0) ,	// input  S0
	.S1(S1) ,	// input  S1
	.S2(S2) ,	// input  S2
	.S3(S3) ,	// input  S3
	.S4(S4) ,	// input  S4
	.S5(S5) ,	// input  S5
	.S6(S6) ,	// input  S6
	.S7(S7) ,	// input  S7
	.RD_N(PAD_RD_N) ,	// input  RD_N
	.IORQ_N(PAD_IORQ_N) ,	// input  IORQ_N
	.PHI_N(PAD_PHI_N) ,	// output  PHI_N
	.RAS_N(PAD_RAS_N) ,	// output  RAS_N
	.READY(PAD_READY) ,	// output  READY
	.CASAD_N(PAD_CASAD_N) ,	// output  CASAD_N
	.CPU_N(PAD_CPU_N) ,	// output  CPU_N
	.CCLK(PAD_CCLK) ,	// output  CCLK
	.MWE_N(PAD_MWE_N) ,	// output  MWE_N
	.E244_N(PAD_244E_N) 	// output  E244_N. NOTE: Had to put the "E" at the start on the signal name (on the module).
);

cas_generation cas_generation_inst
(
	.RESET(U121) ,	// input  RESET
	.M1_N(PAD_M1_N) ,	// input  M1_N
	.PHI_N(PAD_PHI_N) ,	// input  PHI_N
	.MREQ_N(PAD_MREQ_N) ,	// input  MREQ_N
	.S0(S0) ,	// input  S0
	.S1(S1) ,	// input  S1
	.S2(S2) ,	// input  S2
	.S3(S3) ,	// input  S3
	.S4(S4) ,	// input  S4
	.S5(S5) ,	// input  S5
	.S6(S6) ,	// input  S6
	.S7(S7) ,	// input  S7
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.CAS_N(PAD_CAS_N) 	// output  CAS_N
);


wire [4:2] HCNT;
wire IRQ_RESET;
wire MODE_SYNC;
sync_gen sync_gen_inst
(
	.HSYNC(PAD_HSYNC) ,	// input  HSYNC
	.CCLK(PAD_CCLK) ,		// input  CCLK
	.RESET(U121) ,			// input  RESET
	.VSYNC(PAD_VSYNC) ,	// input  VSYNC
	.IORQ_N(PAD_IORQ_N) ,	// input  IORQ_N
	.M1_N(PAD_M1_N) ,			// input  M1_N
	.IRQ_RESET(IRQ_RESET) ,	// input  IRQ_RESET
	.NSYNC(PAD_SYNC_N) ,		// output  NSYNC
	.MODE_SYNC(MODE_SYNC) ,	// output  MODE_SYNC
	.HCNT(HCNT) ,				// output [4:2] HCNT
	.INT_N(PAD_INT_N) 		// output  INT_N
);

wire [15:0] INKR4;
wire [15:0] INKR3;
wire [15:0] INKR2;
wire [15:0] INKR1;
wire [15:0] INKR0;
wire [1:0] MODE;
wire [4:0] BORDER;
wire HROMEN;
wire LROMEN;
registers registers_inst
(
	.RESET(U121) ,	// input  RESET
	.M1_N(PAD_M1_N) ,	// input  M1_N
	.A14(PAD_A14) ,		// input  A14
	.A15(PAD_A15) ,		// input  A15
	.IORQ_N(PAD_IORQ_N) ,	// input  IORQ_N
	.S0(S0) ,	// input  S0
	.S7(S7) ,	// input  S7
	.D(PAD_D) ,		// input [7:0] D
	.BORDER(BORDER) ,	// output [4:0] BORDER
	.IRQ_RESET(IRQ_RESET) ,	// output  IRQ_RESET
	.HROMEN(HROMEN) ,	// output  HROMEN
	.LROMEN(LROMEN) ,	// output  LROMEN
	.MODE(MODE) ,		// output [1:0] MODE
	.INKR4(INKR4) ,	// output [15:0] INKR4
	.INKR3(INKR3) ,	// output [15:0] INKR3
	.INKR2(INKR2) ,	// output [15:0] INKR2
	.INKR1(INKR1) ,	// output [15:0] INKR1
	.INKR0(INKR0) 		// output [15:0] INKR0
);


rom_ram_mapping rom_ram_mapping_inst
(
	.LROMEN(LROMEN) ,	// input  LROMEN
	.A15(PAD_A15) ,	// input  A15
	.A14(PAD_A14) ,	// input  A14
	.HROMEN(HROMEN) ,	// input  HROMEN
	.MREQ_N(PAD_MREQ_N) ,	// input  MREQ_N
	.RD_N(PAD_RD_N) ,	// input  RD_N
	.ROMEN_N(PAD_ROMEN_N) ,	// output  ROMEN_N
	.RAMRD_N(PAD_RAMRD_N) 	// output  RAMRD_N
);

wire DISPEN_BUF;
wire [7:0] VIDEO_BUF;
video_buffer video_buffer_inst
(
	.DISPEN(PAD_DISPEN) ,	// input  DISPEN
	.S3(S3) ,	// input  S3
	.CAS_N_IN(PAD_CAS_N) ,	// input  CAS_N_IN
	.D(PAD_D) ,	// input [7:0] D
	.DISPEN_BUF(DISPEN_BUF) ,	// output  DISPEN_BUF
	.VIDEO_BUF(VIDEO_BUF) 	// output [7:0] VIDEO_BUF
);

wire LOAD;
wire COLOUR_KEEP;
wire INK_SEL;
wire BORDER_SEL;
wire SHIFT;
wire KEEP;
wire MODE_IS_2;
wire MODE_IS_0;
wire BLUE_OE_N;
wire BLUE;
wire GREEN_OE_N;
wire GREEN;
wire RED_OE_N;
wire RED;
video_control video_control_inst
(
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.DISPEN_BUF(DISPEN_BUF) ,	// input  DISPEN_BUF
	.S5(S5) ,	// input  S5
	.S6(S6) ,	// input  S6
	.PHI_N(PAD_PHI_N) ,	// input  PHI_N
	.MODE(MODE) ,	// input [1:0] MODE
	.MODE_SYNC(MODE_SYNC) ,	// input  MODE_SYNC
	.LOAD(LOAD) ,	// output  LOAD
	.COLOUR_KEEP(COLOUR_KEEP) ,	// output  COLOUR_KEEP
	.INK_SEL(INK_SEL) ,	// output  INK_SEL
	.BORDER_SEL(BORDER_SEL) ,	// output  BORDER_SEL
	.SHIFT(SHIFT) ,	// output  SHIFT
	.KEEP(KEEP) ,	// output  KEEP
	.MODE_IS_2(MODE_IS_2) ,	// output  MODE_IS_2
	.MODE_IS_0(MODE_IS_0) 	// output  MODE_IS_0
);

wire [3:0] CIDX;
video_shift video_shift_inst
(
	.VIDEO(VIDEO_BUF) ,	// input [7:0] VIDEO
	.KEEP(KEEP) ,	// input  KEEP
	.LOAD(LOAD) ,	// input  LOAD
	.SHIFT(SHIFT) ,	// input  SHIFT
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.CIDX(CIDX) 	// output [3:0] CIDX
);

wire [4:0] COLOUR;
colour_mux_full colour_mux_full_inst
(
	.BORDER(BORDER) ,	// input [4:0] BORDER
	.INKR4(INKR4) ,	// input [15:0] INKR4
	.INKR3(INKR3) ,	// input [15:0] INKR3
	.INKR2(INKR2) ,	// input [15:0] INKR2
	.INKR1(INKR1) ,	// input [15:0] INKR1
	.INKR0(INKR0) ,	// input [15:0] INKR0
	.COLOUR_KEEP(COLOUR_KEEP) ,	// input  COLOUR_KEEP
	.INK_SEL(INK_SEL) ,	// input  INK_SEL
	.BORDER_SEL(BORDER_SEL) ,	// input  BORDER_SEL
	.MODE_IS_0(MODE_IS_0) ,	// input  MODE_IS_0
	.MODE_IS_2(MODE_IS_2) ,	// input  MODE_IS_2
	.CIDX(CIDX) ,	// input [3:0] CIDX
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.COLOUR(COLOUR) 	// output [4:0] COLOUR
);


colour_decode colour_decode_inst
(
	.HCNT(HCNT) ,	// input [4:2] HCNT
	.HSYNC(PAD_HSYNC) ,	// input  HSYNC
	.COLOUR(COLOUR) ,	// input [4:0] COLOUR
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.BLUE_OE_N(BLUE_OE_N) ,	// output  BLUE_OE_N
	.BLUE(BLUE) ,	// output  BLUE
	.GREEN_OE_N(GREEN_OE_N) ,	// output  GREEN_OE_N
	.GREEN(GREEN) ,	// output  GREEN
	.RED_OE_N(RED_OE_N) ,	// output  RED_OE_N
	.RED(RED) 	// output  RED
);

assign PAD_RED = (!RED_OE_N) ? RED : 1'bz;
assign PAD_GREEN = (!GREEN_OE_N) ? GREEN : 1'bz;
assign PAD_BLUE = (!BLUE_OE_N) ? BLUE : 1'bz;

endmodule



// PDF page 2...
module sequencer (
	input RESET,
	input M1_N,
	input IORQ_N,
	input RD_N,
	
	input CLK_16M_N,
	
	output S0,
	output S1,
	output S2,
	output S3,
	output S4,
	output S5,
	output S6,
	output S7
);

wire U202 = RESET & !M1_N & !IORQ_N & !RD_N;

wire U215 = U216_REG & !U217_REG;

wire U204 = U202 | U215;

reg U201_REG;
reg U205_REG;
reg U207_REG;
reg U209_REG;
reg U211_REG;
reg U213_REG;
reg U216_REG;
reg U217_REG;

always @(posedge CLK_16M_N) U201_REG <= !U217_REG;
always @(posedge CLK_16M_N) U205_REG <= U204 | U201_REG;	// U203 is the OR gate.
always @(posedge CLK_16M_N) U207_REG <= U204 | U205_REG;	// U206 is the OR gate.
always @(posedge CLK_16M_N) U209_REG <= U204 | U207_REG;	// U208 is the OR gate.
always @(posedge CLK_16M_N) U211_REG <= U204 | U209_REG;	// U210 is the OR gate.
always @(posedge CLK_16M_N) U213_REG <= U204 | U211_REG;	// U212 is the OR gate.
always @(posedge CLK_16M_N) U216_REG <= U204 | U213_REG;	// U214 is the OR gate.
always @(posedge CLK_16M_N) U217_REG <= U216_REG;

assign S0 = U201_REG;
assign S1 = U205_REG;
assign S2 = U207_REG;
assign S3 = U209_REG;
assign S4 = U211_REG;
assign S5 = U213_REG;
assign S6 = U216_REG;
assign S7 = U217_REG;

endmodule



// PDF page 3...
module sequence_decoder (
	input CLK_16M_N,
	
	input S0,
	input S1,
	input S2,
	input S3,
	input S4,
	input S5,
	input S6,
	input S7,
		
	input RD_N,
	input IORQ_N,

	output reg PHI_N,
	output reg RAS_N,
	output READY,
	output CASAD_N,
	output CPU_N,
	output CCLK,
	output MWE_N,
	output E244_N
);


always @(posedge CLK_16M_N) PHI_N <= (S1 ^ S3) | (S5 ^ S7);

always @(posedge CLK_16M_N) RAS_N <= (S6 | !S2) & S0;


reg CASAD_REG;
always @(posedge CLK_16M_N) CASAD_REG <= !RAS_N;
assign CASAD_N = !CASAD_REG;


wire U314 = READY & CASAD_REG;
wire U304 = ! (S3 & !S6);

assign READY = U314 & U304;

assign CPU_N = ! (S1 & !S7);

assign CCLK = S2 | S5;

assign MWE_N = ! (S0 & S5 & RD_N);

assign E244_N = ! (S2 & S3 & !IORQ_N);

endmodule



// PDF pages 4 and 5...
module registers(
	input RESET,
	input M1_N,
	input A14,
	input A15,
	input IORQ_N,
	input S0,
	input S7,
	
	input [7:0] D,
	
	output reg [4:0] BORDER,
	output IRQ_RESET,
	output reg HROMEN,
	output reg LROMEN,
	output reg [1:0] MODE,
	
	output reg [15:0] INKR4,
	output reg [15:0] INKR3,
	output reg [15:0] INKR2,
	output reg [15:0] INKR1,
	output reg [15:0] INKR0
	
	/*
	// Extra 32 colours...
	output reg [31:0] INKR4,
	output reg [31:0] INKR3,
	output reg [31:0] INKR2,
	output reg [31:0] INKR1,
	output reg [31:0] INKR0
	*/
);


wire U401 = M1_N & A14 & !A15 & !IORQ_N & S0 & S7;

wire U402 = U401 & !D[7] & !D[6];

wire U408 = U401 & !D[7] & D[6] & INKSEL[4];

wire U414 = U401 & D[7] & !D[6];

reg [4:0] INKSEL;
always @(posedge U402) INKSEL <= D[4:0];

always @(posedge U408) BORDER <= D[4:0];


assign IRQ_RESET = U414 & D[4];

always @(posedge U414) HROMEN <= D[3];
always @(posedge U414) LROMEN <= D[2];
always @(posedge U414) MODE[1] <= D[1];
always @(posedge U414) MODE[0] <= D[0];


wire U420 = U401 & !D[7] & D[6];

wire INKR_0_E  = U420 & INKSEL == 5'b00000;
wire INKR_1_E  = U420 & INKSEL == 5'b00001;
wire INKR_2_E  = U420 & INKSEL == 5'b00010;
wire INKR_3_E  = U420 & INKSEL == 5'b00011;
wire INKR_4_E  = U420 & INKSEL == 5'b00100;
wire INKR_5_E  = U420 & INKSEL == 5'b00101;
wire INKR_6_E  = U420 & INKSEL == 5'b00110;
wire INKR_7_E  = U420 & INKSEL == 5'b00111;
wire INKR_8_E  = U420 & INKSEL == 5'b01000;
wire INKR_9_E  = U420 & INKSEL == 5'b01001;
wire INKR_10_E = U420 & INKSEL == 5'b01010;
wire INKR_11_E = U420 & INKSEL == 5'b01011;
wire INKR_12_E = U420 & INKSEL == 5'b01100;
wire INKR_13_E = U420 & INKSEL == 5'b01101;
wire INKR_14_E = U420 & INKSEL == 5'b01110;
wire INKR_15_E = U420 & INKSEL == 5'b01111;

always @(posedge INKR_0_E)  {INKR4[0],  INKR3[0],  INKR2[0],  INKR1[0],  INKR0[0]} <= D[4:0];
always @(posedge INKR_1_E)  {INKR4[1],  INKR3[1],  INKR2[1],  INKR1[1],  INKR0[1]} <= D[4:0];
always @(posedge INKR_2_E)  {INKR4[2],  INKR3[2],  INKR2[2],  INKR1[2],  INKR0[2]} <= D[4:0];
always @(posedge INKR_3_E)  {INKR4[3],  INKR3[3],  INKR2[3],  INKR1[3],  INKR0[3]} <= D[4:0];
always @(posedge INKR_4_E)  {INKR4[4],  INKR3[4],  INKR2[4],  INKR1[4],  INKR0[4]} <= D[4:0];
always @(posedge INKR_5_E)  {INKR4[5],  INKR3[5],  INKR2[5],  INKR1[5],  INKR0[5]} <= D[4:0];
always @(posedge INKR_6_E)  {INKR4[6],  INKR3[6],  INKR2[6],  INKR1[6],  INKR0[6]} <= D[4:0];
always @(posedge INKR_7_E)  {INKR4[7],  INKR3[7],  INKR2[7],  INKR1[7],  INKR0[7]} <= D[4:0];
always @(posedge INKR_8_E)  {INKR4[8],  INKR3[8],  INKR2[8],  INKR1[8],  INKR0[8]} <= D[4:0];
always @(posedge INKR_9_E)  {INKR4[9],  INKR3[9],  INKR2[9],  INKR1[9],  INKR0[9]} <= D[4:0];
always @(posedge INKR_10_E) {INKR4[10], INKR3[10], INKR2[10], INKR1[10], INKR0[10]} <= D[4:0];
always @(posedge INKR_11_E) {INKR4[11], INKR3[11], INKR2[11], INKR1[11], INKR0[11]} <= D[4:0];
always @(posedge INKR_12_E) {INKR4[12], INKR3[12], INKR2[12], INKR1[12], INKR0[12]} <= D[4:0];
always @(posedge INKR_13_E) {INKR4[13], INKR3[13], INKR2[13], INKR1[13], INKR0[13]} <= D[4:0];
always @(posedge INKR_14_E) {INKR4[14], INKR3[14], INKR2[14], INKR1[14], INKR0[14]} <= D[4:0];
always @(posedge INKR_15_E) {INKR4[15], INKR3[15], INKR2[15], INKR1[15], INKR0[15]} <= D[4:0];


// Extra 32 colours!...
/*
wire INKR_16_E = U420 & INKSEL == 5'b10000;
wire INKR_17_E = U420 & INKSEL == 5'b10001;
wire INKR_18_E = U420 & INKSEL == 5'b10010;
wire INKR_19_E = U420 & INKSEL == 5'b10011;
wire INKR_20_E = U420 & INKSEL == 5'b10100;
wire INKR_21_E = U420 & INKSEL == 5'b10101;
wire INKR_22_E = U420 & INKSEL == 5'b10110;
wire INKR_23_E = U420 & INKSEL == 5'b10111;
wire INKR_24_E = U420 & INKSEL == 5'b11000;
wire INKR_25_E = U420 & INKSEL == 5'b11001;
wire INKR_26_E = U420 & INKSEL == 5'b11010;
wire INKR_27_E = U420 & INKSEL == 5'b11011;
wire INKR_28_E = U420 & INKSEL == 5'b11100;
wire INKR_29_E = U420 & INKSEL == 5'b11101;
wire INKR_30_E = U420 & INKSEL == 5'b11110;
wire INKR_31_E = U420 & INKSEL == 5'b11111;

always @(posedge INKR_16_E) {INKR4[16], INKR3[16], INKR2[16], INKR1[16], INKR0[16]} <= D[4:0];
always @(posedge INKR_17_E) {INKR4[17], INKR3[17], INKR2[17], INKR1[17], INKR0[17]} <= D[4:0];
always @(posedge INKR_18_E) {INKR4[18], INKR3[18], INKR2[18], INKR1[18], INKR0[18]} <= D[4:0];
always @(posedge INKR_19_E) {INKR4[19], INKR3[19], INKR2[19], INKR1[19], INKR0[19]} <= D[4:0];
always @(posedge INKR_20_E) {INKR4[20], INKR3[20], INKR2[20], INKR1[20], INKR0[20]} <= D[4:0];
always @(posedge INKR_21_E) {INKR4[21], INKR3[21], INKR2[21], INKR1[21], INKR0[21]} <= D[4:0];
always @(posedge INKR_22_E) {INKR4[22], INKR3[22], INKR2[22], INKR1[22], INKR0[22]} <= D[4:0];
always @(posedge INKR_23_E) {INKR4[23], INKR3[23], INKR2[23], INKR1[23], INKR0[23]} <= D[4:0];
always @(posedge INKR_24_E) {INKR4[24], INKR3[24], INKR2[24], INKR1[24], INKR0[24]} <= D[4:0];
always @(posedge INKR_25_E) {INKR4[25], INKR3[25], INKR2[25], INKR1[25], INKR0[25]} <= D[4:0];
always @(posedge INKR_26_E) {INKR4[26], INKR3[26], INKR2[26], INKR1[26], INKR0[26]} <= D[4:0];
always @(posedge INKR_27_E) {INKR4[27], INKR3[27], INKR2[27], INKR1[27], INKR0[27]} <= D[4:0];
always @(posedge INKR_28_E) {INKR4[28], INKR3[28], INKR2[28], INKR1[28], INKR0[28]} <= D[4:0];
always @(posedge INKR_29_E) {INKR4[29], INKR3[29], INKR2[29], INKR1[29], INKR0[29]} <= D[4:0];
always @(posedge INKR_30_E) {INKR4[30], INKR3[30], INKR2[30], INKR1[30], INKR0[30]} <= D[4:0];
always @(posedge INKR_31_E) {INKR4[31], INKR3[31], INKR2[31], INKR1[31], INKR0[31]} <= D[4:0];
*/

endmodule



// PDF page 6...
module rom_ram_mapping (
	input LROMEN,
	input A15,
	input A14,
	input HROMEN,
	input MREQ_N,
	input RD_N,
	
	output ROMEN_N,
	output RAMRD_N
);

wire U601 = !LROMEN & !A15 & !A14;

wire U602 = A15 & A14 & !HROMEN;

wire ROM = U601 | U602; // U603

assign ROMEN_N = !ROM | MREQ_N | RD_N;	// U604.

assign RAMRD_N = ROM | MREQ_N | RD_N;		// U605.

endmodule



// PDF page 7...
module cas_generation (
	input RESET,
	input M1_N,
	input PHI_N,
	input MREQ_N,
	input S0,
	input S1,
	input S2,
	input S3,
	input S4,
	input S5,
	input S6,
	input S7,
	
	input CLK_16M_N,
	
	output CAS_N
);

reg U705_REG;
always @(posedge PHI_N) U705_REG <= M1_N;


wire U707 = !M1_N | U705_REG;

reg U708_REG;
always @(posedge MREQ_N)
	if (!U707) U708_REG <= 1'b0;	// Reset. 
	else U708_REG <= 1'b1;			// Else, Clock in a "1".

	
wire U701 = !S4 & S5;
wire U702 = !S3 & S1;
wire U703 = S1 & S7;

wire U704 = U701 | U702 | U703;

reg U706_REG;
always @(posedge CLK_16M_N) U706_REG <= U704;

reg U709_REG;
always @(posedge CLK_16M_N) U709_REG <= U706_REG;


wire U710 = !U708_REG | MREQ_N | !S5 | S5;

wire U711 = U706_REG | U712;

wire U712 = U710 & S2 & U711;

assign CAS_N = U712 | U706_REG | U709_REG;		// U713.


endmodule



// PDF Page 8...
module sync_gen (
	input HSYNC,
	input CCLK,
	input RESET,
	input VSYNC,
	input IORQ_N,
	input M1_N,
	input IRQ_RESET,
	
	output NSYNC,
	output MODE_SYNC,
	output [4:2] HCNT,
	
	output INT_N
);


wire U807 = INTCNT[2] & INTCNT[4] & INTCNT[5];
wire U811 = U807 | U816;
wire U816 = U801 & U811;

wire U806 = !HCNT[2] & !HCNT[3] & !HCNT[4];

reg U812_REG;
always @(posedge CCLK) U812_REG <= U806;

wire U817 = U806 & !U812_REG;

wire U831 = U816 | U817 | IRQ_RESET;

wire U801 = !HSYNC;
wire U804 = U801 & U824_REG;


// INTCNT [045] Register...
reg [5:0] INTCNT;

wire INTCNT1_CLK = !INTCNT[0];
wire INTCNT2_CLK = !INTCNT[1];
wire INTCNT3_CLK = !INTCNT[2];
wire INTCNT4_CLK = !INTCNT[3];
wire INTCNT5_CLK = !INTCNT[4];

always @(posedge U801) if (U831) INTCNT[0] <= 1'b0; else INTCNT[0] <= !INTCNT[0]; 				// U815 reg.
always @(posedge INTCNT1_CLK) if (U831) INTCNT[1] <= 1'b0; else INTCNT[1] <= !INTCNT[1];			// U821 reg.
always @(posedge INTCNT2_CLK) if (U831) INTCNT[2] <= 1'b0; else INTCNT[2] <= !INTCNT[2];			// U826 reg.
always @(posedge INTCNT3_CLK) if (U831) INTCNT[3] <= 1'b0; else INTCNT[3] <= !INTCNT[3];			// U830 reg.
always @(posedge INTCNT4_CLK) if (U831) INTCNT[4] <= 1'b0; else INTCNT[4] <= !INTCNT[4];			// U832 reg.
always @(posedge INTCNT5_CLK) if (U831 | U827) INTCNT[5] <= 1'b0; else INTCNT[5] <= !INTCNT[5];	// U835 reg.

wire U822 = !VSYNC;


// HSYNC? Reg...
reg U808_REG;
reg U813_REG;
reg U818_REG;
reg U824_REG;

wire U813_CLK = !U808_REG;
wire U818_CLK = !U813_REG;
wire U824_CLK = !U818_REG;

always @(posedge CCLK) if (U804) U808_REG <= 1'b0; else U808_REG <= !U808_REG; 
always @(posedge U813_CLK) if (U804) U813_REG <= 1'b0; else U813_REG <= !U813_REG; 
always @(posedge U818_CLK) if (U804) U818_REG <= 1'b0; else U818_REG <= !U818_REG; 
always @(posedge U824_CLK) if (U822) U824_REG <= 1'b0; else U824_REG <= !U824_REG; // !VSYNC (U822) resets this reg.

wire U828 = U806 ^ U818_REG;
assign NSYNC = U828;	// NSYNC, not "HSYNC". ;)

assign MODE_SYNC = !U818_REG;


// HCNT reg...
wire U802 = HCNT[2] & HCNT[2] & HCNT[4];
wire U805 = RESET | U802;

reg U803_REG;
always @(posedge CCLK) U803_REG <= VSYNC;

wire U810 = VSYNC & !U803_REG;

reg U809_REG;
reg U814_REG;
reg U820_REG;
reg U825_REG;
reg U829_REG;

wire U814_CLK = !U809_REG;
wire U820_CLK = !U814_REG;
wire U825_CLK = !U820_REG;
wire U829_CLK = !U825_REG;

always @(posedge U801) if (U805) U809_REG <= 1'b0; else U809_REG <= !U809_REG;	// U809_REG
always @(posedge U814_CLK) if (U810) U814_REG <= 1'b0; else  U814_REG <= !U814_REG;	// U814_REG
always @(posedge U820_CLK) if (U810) U820_REG <= 1'b0; else  U820_REG <= !U820_REG;	// U820_REG
always @(posedge U825_CLK) if (U810) U825_REG <= 1'b0; else  U825_REG <= !U825_REG;	// U825_REG
always @(posedge U829_CLK) if (U810) U829_REG <= 1'b0; else  U829_REG <= !U829_REG;	// U829_REG


assign HCNT[4] = U829_REG;
assign HCNT[3] = U825_REG;
assign HCNT[2] = U820_REG;


// IRQACK_RST...
wire U819 = ! (INT_N | IORQ_N | M1_N);
wire U823 = U827 | U819;
wire U827 = U823 & !M1_N;

wire U834 = U827 | IRQ_RESET;


// INTerrupt output reg...
wire U836_CLK = !INTCNT[5];

reg U836_REG;
always @(posedge U836_CLK) if (U834) U836_REG <= 1'b0; else U836_REG <= 1'b1;

wire U837 = !U836_REG;
assign INT_N = U837;

endmodule



// PDF page 9...
module video_buffer (
	input DISPEN,
	input S3,
	input CAS_N_IN,
	input [7:0] D,
	
	output reg DISPEN_BUF,
	
	output reg [7:0] VIDEO_BUF
);

wire U901 = S3 | CAS_N_IN;

always @(posedge U901) DISPEN_BUF <= DISPEN;
always @(posedge U901) VIDEO_BUF <= D;

endmodule



// PDF page 10...
module video_control (
	input CLK_16M_N,
	input DISPEN_BUF,
	input S5,
	input S6,
	input PHI_N,
	input [1:0] MODE,
	input MODE_SYNC,
	
	output LOAD,
	output reg COLOUR_KEEP,
	output reg INK_SEL,
	output reg BORDER_SEL,
	output reg SHIFT,
	output reg KEEP,
	
	output MODE_IS_2,
	output MODE_IS_0
);


reg U1005_REG;
always @(posedge CLK_16M_N) U1005_REG <= U1008;

wire U1008 = (U1006_REG) ? DISPEN_BUF : U1005_REG;


wire U1001 = S5 ^ S6;

reg U1006_REG;
always @(posedge CLK_16M_N) U1006_REG <= U1001;

assign LOAD = U1006_REG;


wire U1002 = !PHI_N;

reg U1007_REG;
always @(posedge CLK_16M_N) U1007_REG <= U1002;


wire U1012 = !U1013_REG | U1006_REG;

reg U1013_REG;
always @(posedge CLK_16M_N) U1013_REG <= U1012;


wire U1016 = U1013_REG | MODE_IS_2;
wire U1018 = !U1016;
wire U1019 = U1008 & U1016;
wire U1020 = !U1008 & U1016;


wire U1014 = U1007_REG & U1013_REG;
wire U1015 = U1013_REG & MODE_IS_1;
wire U1017 = MODE_IS_2 | U1014 | U1015;

wire U1021 = !U1001 & U1017;
wire U1022 = !U1017;


always @(posedge CLK_16M_N) COLOUR_KEEP <= U1018;	// Reg U1023
always @(posedge CLK_16M_N) INK_SEL     <= U1019;	// Reg U1024
always @(posedge CLK_16M_N) BORDER_SEL  <= U1020;	// Reg U1025
always @(posedge CLK_16M_N) SHIFT       <= U1021;	// Reg U1026
always @(posedge CLK_16M_N) KEEP        <= U1022;	// Reg U1027


reg U1003_REG;
always @(posedge MODE_SYNC) U1003_REG <= MODE[0];

reg U1004_REG;
always @(posedge MODE_SYNC) U1004_REG <= MODE[1];

assign MODE_IS_2 = !U1003_REG & U1004_REG;
wire MODE_IS_1 = U1003_REG & !U1004_REG;
assign MODE_IS_0 = !U1003_REG & !U1004_REG;


endmodule



// PDF page 11...
module video_shift (
	input [7:0] VIDEO,
	input KEEP,
	input LOAD,
	input SHIFT,
	
	input CLK_16M_N,
	
	output [3:0] CIDX
);

// Bit 0...
wire U1101 = SHIFT & 1'b0; // (Grounded input?)
wire U1102 = LOAD & VIDEO[0];
wire U1105 = KEEP & U1104_REG;

wire U1103 = U1101 | U1102 | U1105;

reg U1104_REG;
always @(posedge CLK_16M_N) U1104_REG <= U1103;

// Bit 1...
wire U1106 = SHIFT & U1104_REG;	// Input from previous bit reg.
wire U1107 = LOAD & VIDEO[1];
wire U1110 = KEEP & U1104_REG;

wire U1108 = U1106 | U1107 | U1110;

reg U1109_REG;
always @(posedge CLK_16M_N) U1109_REG <= U1108;

// Bit 2...
wire U1111 = SHIFT & U1109_REG;	// Input from previous bit reg.
wire U1112 = LOAD & VIDEO[2];
wire U1115 = KEEP & U1104_REG;

wire U1113 = U1111 | U1112 | U1115;

reg U1114_REG;
always @(posedge CLK_16M_N) U1114_REG <= U1113;

// Bit 3...
wire U1116 = SHIFT & U1114_REG;	// Input from previous bit reg.
wire U1117 = LOAD & VIDEO[3];
wire U1120 = KEEP & U1104_REG;

wire U1118 = U1116 | U1117 | U1120;

reg U1119_REG;
always @(posedge CLK_16M_N) U1119_REG <= U1118;

// Bit 4...
wire U1121 = SHIFT & U1119_REG;	// Input from previous bit reg.
wire U1122 = LOAD & VIDEO[4];
wire U1125 = KEEP & U1104_REG;

wire U1123 = U1121 | U1122 | U1125;

reg U1124_REG;
always @(posedge CLK_16M_N) U1124_REG <= U1123;

// Bit 5...
wire U1126 = SHIFT & U1124_REG;	// Input from previous bit reg.
wire U1127 = LOAD & VIDEO[5];
wire U1130 = KEEP & U1104_REG;

wire U1128 = U1126 | U1127 | U1130;

reg U1129_REG;
always @(posedge CLK_16M_N) U1129_REG <= U1128;

// Bit 6...
wire U1131 = SHIFT & U1129_REG;	// Input from previous bit reg.
wire U1132 = LOAD & VIDEO[6];
wire U1135 = KEEP & U1104_REG;

wire U1133 = U1131 | U1132 | U1135;

reg U1134_REG;
always @(posedge CLK_16M_N) U1134_REG <= U1133;

// Bit 7...
wire U1136 = SHIFT & U1134_REG;	// Input from previous bit reg.
wire U1137 = LOAD & VIDEO[7];
wire U1140 = KEEP & U1104_REG;

wire U1138 = U1136 | U1137 | U1140;

reg U1139_REG;
always @(posedge CLK_16M_N) U1139_REG <= U1138;


endmodule



// PDF page 12...
module colour_mux_full (
	input [4:0] BORDER,
	
	input [15:0] INKR4,
	input [15:0] INKR3,
	input [15:0] INKR2,
	input [15:0] INKR1,
	input [15:0] INKR0,
	
	input COLOUR_KEEP,
	input INK_SEL,
	input BORDER_SEL,
	input MODE_IS_0,
	input MODE_IS_2,
	input [3:0] CIDX,
	
	input CLK_16M_N,
	
	output [4:0] COLOUR
);


colour_mux_bit colour_mux_bit_4
(
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.COLOUR_KEEP(COLOUR_KEEP) ,	// input  COLOUR_KEEP
	.BORDER_SEL(BORDER_SEL) ,	// input  BORDER_SEL
	.BORDER(BORDER[4]) ,	// input  BORDER
	.INK_SEL(INK_SEL) ,	// input  INK_SEL
	.INKR(INKR4) ,	// input [15:0] INKR
	.CIDX(CIDX) ,		// input [3:0] CIDX
	.MODE_IS_0(MODE_IS_0) ,	// input  MODE_IS_0
	.MODE_IS_2(MODE_IS_2) ,	// input  MODE_IS_2
	.INK(COLOUR[4]) 	// output  INK
);

colour_mux_bit colour_mux_bit_3
(
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.COLOUR_KEEP(COLOUR_KEEP) ,	// input  COLOUR_KEEP
	.BORDER_SEL(BORDER_SEL) ,	// input  BORDER_SEL
	.BORDER(BORDER[3]) ,	// input  BORDER
	.INK_SEL(INK_SEL) ,	// input  INK_SEL
	.INKR(INKR3) ,	// input [15:0] INKR
	.CIDX(CIDX) ,		// input [3:0] CIDX
	.MODE_IS_0(MODE_IS_0) ,	// input  MODE_IS_0
	.MODE_IS_2(MODE_IS_2) ,	// input  MODE_IS_2
	.INK(COLOUR[3]) 	// output  INK
);

colour_mux_bit colour_mux_bit_2
(
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.COLOUR_KEEP(COLOUR_KEEP) ,	// input  COLOUR_KEEP
	.BORDER_SEL(BORDER_SEL) ,	// input  BORDER_SEL
	.BORDER(BORDER[2]) ,	// input  BORDER
	.INK_SEL(INK_SEL) ,	// input  INK_SEL
	.INKR(INKR2) ,	// input [15:0] INKR
	.CIDX(CIDX) ,		// input [3:0] CIDX
	.MODE_IS_0(MODE_IS_0) ,	// input  MODE_IS_0
	.MODE_IS_2(MODE_IS_2) ,	// input  MODE_IS_2
	.INK(COLOUR[2]) 	// output  INK
);

colour_mux_bit colour_mux_bit_1
(
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.COLOUR_KEEP(COLOUR_KEEP) ,	// input  COLOUR_KEEP
	.BORDER_SEL(BORDER_SEL) ,	// input  BORDER_SEL
	.BORDER(BORDER[1]) ,	// input  BORDER
	.INK_SEL(INK_SEL) ,	// input  INK_SEL
	.INKR(INKR1) ,	// input [15:0] INKR
	.CIDX(CIDX) ,		// input [3:0] CIDX
	.MODE_IS_0(MODE_IS_0) ,	// input  MODE_IS_0
	.MODE_IS_2(MODE_IS_2) ,	// input  MODE_IS_2
	.INK(COLOUR[1]) 	// output  INK
);

colour_mux_bit colour_mux_bit_0
(
	.CLK_16M_N(CLK_16M_N) ,	// input  CLK_16M_N
	.COLOUR_KEEP(COLOUR_KEEP) ,	// input  COLOUR_KEEP
	.BORDER_SEL(BORDER_SEL) ,	// input  BORDER_SEL
	.BORDER(BORDER[0]) ,	// input  BORDER
	.INK_SEL(INK_SEL) ,	// input  INK_SEL
	.INKR(INKR0) ,	// input [15:0] INKR
	.CIDX(CIDX) ,		// input [3:0] CIDX
	.MODE_IS_0(MODE_IS_0) ,	// input  MODE_IS_0
	.MODE_IS_2(MODE_IS_2) ,	// input  MODE_IS_2
	.INK(COLOUR[0]) 	// output  INK
);


endmodule



// PDF Page 13,14,15,16,17...
// (all pages contain duplicates of this block).
//
module colour_mux_bit (
	input CLK_16M_N,

	input COLOUR_KEEP,
	input BORDER_SEL,
	input BORDER,
	input INK_SEL,
	input [15:0] INKR,
	
	input [3:0] CIDX,
	
	input MODE_IS_0,
	input MODE_IS_2,
	
	output reg INK
);

wire U1301 = CIDX[2] & MODE_IS_0;
wire U1302 = CIDX[3] & MODE_IS_0;
wire U1303 = CIDX[1] & !MODE_IS_2;

wire U1304 = !U1301;
wire U1317 = !U1303;


wire U1305 = (U1301 | INKR[7])  & (INKR[3] | U1304);
wire U1306 = (U1301 | INKR[15]) & (INKR[11] | U1304);
wire U1307 = (U1301 | INKR[5])  & (INKR[1] | U1304);
wire U1308 = (U1301 | INKR[13]) & (INKR[9] | U1304);
wire U1309 = (U1301 | INKR[6])  & (INKR[2] | U1304);
wire U1310 = (U1301 | INKR[14]) & (INKR[10] | U1304);
wire U1311 = (U1301 | INKR[4])  & (INKR[0] | U1304);
wire U1312 = (U1301 | INKR[12]) & (INKR[8] | U1304);


wire U1313 = (!U1302) ? U1305 : U1306;
wire U1314 = (!U1302) ? U1307 : U1308;
wire U1315 = (!U1302) ? U1309 : U1310;
wire U1316 = (!U1302) ? U1311 : U1312;

wire U1318 = (U1303 | U1313) & (U1314 | U1317);
wire U1319 = (U1303 | U1315) & (U1316 | U1317);

wire U1320 = INK_SEL & CIDX[0] & U1318;
wire U1321 = INK_SEL & CIDX[0] & U1319;

wire U1322 = INK & COLOUR_KEEP;
wire U1323 = BORDER_SEL & BORDER;

wire U1324 = U1322 | U1323 | U1320 | U1321;

always @(posedge CLK_16M_N) INK <= U1324;

endmodule



// PDF Page 18...
module colour_decode(
	input [4:2] HCNT,
	input HSYNC,
	input [4:0] COLOUR,
	
	input CLK_16M_N,
	
	output reg BLUE_OE_N,
	output reg BLUE,
	
	output reg GREEN_OE_N,
	output reg GREEN,
	
	output reg RED_OE_N,
	output reg RED
);


wire U1801 = HCNT[2] & HCNT[3] & HCNT[4];
wire U1809 = !U1801 | HSYNC;

wire U1802 = COLOUR[1] | COLOUR[2];
wire U1803 = COLOUR[3] | COLOUR[4];
wire U1810 = ! (U1802 & U1803);

wire U1804 = COLOUR[1] & COLOUR[2];
wire U1805 = COLOUR[1] | COLOUR[2] | COLOUR[3] | COLOUR[4];
wire U1806 = COLOUR[2] & !COLOUR[0];
wire U1811 = U1804 | !U1805;
wire U1812 = U1806 | COLOUR[1];


wire U1807 = COLOUR[4] & COLOUR[3];
wire U1808 = !COLOUR[4] & COLOUR[0];
wire U1813 = !U1805 | U1807;
wire U1814 = U1808 | COLOUR[3];


always @(posedge CLK_16M_N) if (U1809) BLUE_OE_N <= 1'b0; else BLUE_OE_N <= U1810;
always @(posedge CLK_16M_N) if (U1809) BLUE <= 1'b0; else BLUE <= COLOUR[0];

always @(posedge CLK_16M_N) if (U1809) GREEN_OE_N <= 1'b0; else GREEN_OE_N <= U1811;
always @(posedge CLK_16M_N) if (U1809) GREEN <= 1'b0; else GREEN <= U1812;

always @(posedge CLK_16M_N) if (U1809) RED_OE_N <= 1'b0; else RED_OE_N <= U1813;
always @(posedge CLK_16M_N) if (U1809) RED <= 1'b0; else RED <= U1814;


endmodule
