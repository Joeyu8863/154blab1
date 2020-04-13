//Author: Joe Yu, Tim Lu (4/12/20)
//submodules for the datapath

module ALU (input [31:0] a, b,input [3:0] f, output reg [31:0] y);
  wire [31:0] BB ;
  wire [31:0] S ;
  wire   cout ;
  
  assign BB = (f[3]) ? ~b : b ;
  assign {cout, S} = f[3] + a + BB ;
  always @ * begin
   case (f[2:0]) //add 1bit, addu,subu,xor,sltu,
    3'b000 : y <= a & BB;//and /u
    3'b001 : y <= a | BB;//or
    3'b010 : y <= S;//add /u
    3'b011 : y <= {31'd0, S[31]};//slt /u
    3'b101 : y <= a ^ BB ;//xor
    3'b110 : y <= a ~^ BB; //xnor
    default: y <= 32'b0;
   endcase
  end 

 endmodule

module data_memory(input clk, write, input[31:0] address, write_data, output [31:0] read_data);

reg [31:0] RAM[63:0];
assign read_data = RAM[address[31:2]];

always@(posedge clk)
begin
	if(write==1'b1) begin
		RAM[address[31:2]]<=write_data;
	end
end

endmodule

module inst_memory(input [5:0] address, output [31:0] read_data);

reg [31:0] RAM[63:0];

initial
    begin
    	$readmemh("memfile.dat",RAM);
    end

assign read_data = RAM[address];

endmodule

module register(input [31:0] D, input R, Clk, En, output reg [31:0] Q); //32-bit 1-input register (synchronous reset and enable)

always @(posedge Clk)
begin
	if(R==1'b1) begin
		Q <= 32'b0;
	end else if (En==1'b1) begin
		Q <= D;
	end
end

endmodule

module reg_file(input [4:0] pr1, pr2, wr, input [31:0] wd, input write, clk, reset, output [31:0] rd1, rd2); //read-and-write register file (synchronous enable)

reg [31:0] register[31:0];

integer i;

initial for (i = 0; i < 32; i = i + 1) begin
	register[i] = 32'b0; 
end

assign rd1 = register[pr1];
assign rd2 = register[pr2];

always @(posedge clk)
begin	
	if(reset==1'b1) begin
		for (i = 0; i < 32; i = i + 1) begin
			register[i] = 32'b0; 
		end
	end
	else if(write==1'b1) begin
		register[wr]<=wd;
	end
end

endmodule

module multiplier(input [31:0] a, b, input clk, start, is_signed, output [63:0] s, output en);

reg [6:0] count = 7'b0;
wire [63:0] c, d;
assign c = is_signed==1'b1 ? {{32{a[31]}},a} : {32'b0, a};
assign d = is_signed==1'b1 ? {{32{b[31]}},b} : {32'b0, b};
reg [127:0] r = 128'b0;
assign s = r[63:0];
assign en = count[6];

always @(posedge start)
begin
	if(start==1'b1) begin
		r = 128'b0;
	end
end

always @(posedge clk)
begin
	if(count[6]==1'b1) begin
		count = 7'b0;
	end else if(start==1'b1) begin
		r[count +: 64] = r[count +: 64] + (d&{64{c[count]}});
		count = count + 1;
	end
end

assign en = (start==1'b1 & count[6]==1'b0);

endmodule

module controller(input [5:0] op,funct,
               output  memtoreg, memwrite,
               output  regdst, regwrite,
               output  jump, b_eq, b_nq,
               output  start_mult, mult_sign,
               output  [1:0] alusrc,            
               output  [1:0] out_select,
               output  [3:0] aluop);//change 1:0 to 3:0
reg [16:0] controls;//change 8:0 to 14:0
assign {memtoreg, memwrite, regdst, regwrite, jump, b_eq, b_nq,
 start_mult, mult_sign, alusrc, out_select, aluop} = controls;//need to adjust

always@(*)
case(op)//ADD  addiu,lui,xori,slti,sltiu,
6'b000000: begin 
case(funct)
                6'b011000: controls <= 17'b00000001100000111;//mul
                6'b011001: controls <= 17'b00000001000000111;//mulu
                6'b010000: controls <= 17'b00110000000100111;//mfhi
                6'b010010: controls <= 17'b00110000000110111;//mflo
                6'b100000: controls <= 17'b00110000000000010;//add
                6'b100001: controls <= 17'b00110000000000010;//addu
		6'b100010: controls <= 17'b00110000000001010;//sub
                6'b100011: controls <= 17'b00110000000001010;//subu
                6'b100100: controls <= 17'b00110000000000000;//and
                6'b100101: controls <= 17'b00110000000000001;//or
                6'b100110: controls <= 17'b00110000000000101;//xor
                6'b000001: controls <= 17'b00110000000000110;//xnor
                6'b101010: controls <= 17'b00110000000000011;//slt
                6'b101011: controls <= 17'b00110000000000011;//sltu
                
                default:   controls <= 17'b00110000000000111; // RTYPE
endcase
end
6'b001000: controls <= 17'b00010000001000010; // ADDI
6'b001001: controls <= 17'b00010000010000010; // ADDIU
6'b001100: controls <= 17'b00010000010000000; // andi
6'b001101: controls <= 17'b00010000010000001; // ori
6'b001110: controls <= 17'b00010000010000101; // xori
6'b001010: controls <= 17'b00010000001000011; // slti
6'b001011: controls <= 17'b00010000010000011; // sltiu
6'b100011: controls <= 17'b10010000001000010; // LW (sign extend)
6'b101011: controls <= 17'b01000000001000010; // SW
6'b001111: controls <= 17'b00010000000010111; // lui
6'b000010: controls <= 17'b00001000000000111; // j
6'b000100: controls <= 17'b00000100000000111; // BEQ
6'b000101: controls <= 17'b00000010000000111; // BNE
default:   controls <= 17'b00000000000000111; // illegal op
endcase

endmodule

module hazard(//pg420 full hazard pg427
input [4:0]rsE,rtE,rsD,rtD,
input [4:0]WriteRegM,WriteRegW,WriteRegE,
input multstall,
output BranchD,RegWriteE,RegWriteM, RegWriteW, flushE,MemtoRegE,MemtoRegM,stallF,stallD,stallE,stallM,stallW,ForwardAD,ForwardBD,
output reg [1:0]ForwardAE, ForwardBE);
 always @ * begin
if ((rsE != 5'b0) & (rsE== WriteRegM) & (RegWriteM == 1'b1)) //The generate if condition must be a constant expression.what's problem
                        ForwardAE <= 2'b10;//lw 
else if ((rsE != 5'b0) & (rsE== WriteRegW) & (RegWriteW == 1'b1))  
                        ForwardAE <= 2'b01; 
else 
    ForwardAE <= 2'b00;
if ((rtE != 5'b0) & (rtE== WriteRegM) & (RegWriteM == 1'b1)) //The generate if condition must be a constant expression.what's problem
                        ForwardBE <= 2'b10;//lw 
else if ((rtE != 5'b0) & (rtE== WriteRegW) & (RegWriteW == 1'b1))  
                        ForwardBE <= 2'b01; 
else 
    ForwardBE <= 2'b00;

end
assign ForwardAD = (rsD != 5'b0) &(rsD == WriteRegM) & RegWriteM;//branch pg425
assign ForwardBD = (rtD != 5'b0) & (rtD == WriteRegM) & RegWriteM;
wire branchstall = BranchD & RegWriteE & (WriteRegE == rsD | WriteRegE == rtD) | BranchD & MemtoRegM & (WriteRegM == rsD | WriteRegM == rtD);

wire lwstall = ((rsD==rtE) | (rtD==rtE)) & MemtoRegE; 
assign stallF = lwstall | branchstall;
assign stallD = stallF;
assign flushE = stallD;
assign stallE = multstall;
assign stallM = multstall;
assign stallW = multstall;
endmodule

module decodestage ( input [31:0] instr,
                     input [31:0] pcplus4f,
                     input clk, reset,
                     input enable, clear,
                     output reg[31:0] pcplus4d,
                     output reg[31:0] instrd);

always@(posedge clk)
begin
if(clear == 1'b0 & reset == 1'b0)
begin
pcplus4d <= pcplus4f;
instrd <= instr;
end else if(enable == 1'b0) begin
pcplus4d <= 32'b0;
instrd <= 32'b0;
end
end
endmodule

module executionstage (input RegWriteD,
                      input MemtoRegD,
                      input MemWriteD,start_multD,mult_signD,
                      input [3:0] ALUControlD,
		      input [1:0] outSelectD, alusrcD,
		      input [4:0] RsD, RtD, RdD,
		      input [31:0] s_id, z_id, r_d1, r_d2,
                      input clk, reset, RegDstD,
                      input FlushE,enable,
		      output reg [31:0] s_ie, z_ie, r_e1, r_e2,
                      output reg RegWriteE,
                      output reg MemtoRegE,
                      output reg MemWriteE,start_multE,mult_signE,
		      output reg [4:0] RsE, RtE, RdE,
                      output reg [3:0] ALUControlE,
		      output reg [1:0] outSelectE, alusrcE,
                      output reg RegDstE);
always@(posedge clk)
begin
if(FlushE == 1'b0 & reset == 1'b0)
begin
 RegWriteE <= RegWriteD;
 MemtoRegE <= MemtoRegD;
 MemWriteE <= MemWriteD;
 start_multE <= start_multD;
 mult_signE <= mult_signD;
 ALUControlE <= ALUControlD;
 outSelectE <= outSelectD;
 alusrcE <= alusrcD;
 RegDstE <= RegDstD;
 RsE <= RsD;
 RtE <= RtD;
 RdE <= RdD;
 s_ie <= s_id;
 z_ie <= z_id;
 r_e1 <= r_d1;
 r_e2 <= r_d2;
end
else if(enable==1'b1)
begin
RegWriteE <= 1'b0;
MemtoRegE <= 1'b0;
MemWriteE <= 1'b0;
start_multE <= 1'b0;
mult_signE <= 1'b0;
ALUControlE <= 4'b0;
outSelectE <= 2'b0;
alusrcE <= 2'b0;
RegDstE <= 1'b0;
RsE <= 5'b0;
RtE <= 5'b0;
RdE <= 5'b0;
s_ie <= 32'b0;
z_ie <= 32'b0;
r_e1 <= 32'b0;
r_e2 <= 32'b0;
end
end
endmodule

module memstage (input RegWriteE,
                 input MemtoRegE,
                 input MemWriteE,
                 input clk,enable,reset,
		 input [4:0] wr_e,
		 input [31:0] wd_e, o_e,
		 output reg [4:0] wr_m,
                 output reg RegWriteM,
                 output reg MemtoRegM,
		 output reg [31:0] wd_m, ao_m,
                 output reg MemWriteM);
always@(posedge clk)
begin
	if (reset == 1'b1) begin
		RegWriteM <= 1'b0;
		MemtoRegM <= 1'b0;
		MemWriteM <= 1'b0;
		wr_m <= 5'b0;
		wd_m <= 32'b0;
		ao_m <= 32'b0;
	end
	else if (enable==1'b1) begin
		RegWriteM <= RegWriteE;
		MemtoRegM <= MemtoRegE;
		MemWriteM <= MemWriteE;
		wr_m <= wr_e;
		wd_m <= wd_e;
		ao_m <= o_e;
	end
end
endmodule

module writestage (input RegWriteM,
                   input MemtoRegM,
                   input clk,enable,reset,
		   input [4:0] wr_m,
		   input [31:0] ao_m, rd_m,
		   output reg [4:0] wr_w,
		   output reg [31:0] ao_w, rd_w,
                   output reg RegWriteW,
                   output reg MemtoRegW);
always@(posedge clk)
begin
	if (reset == 1'b0)begin
		RegWriteW <= 1'b0;
		MemtoRegW <= 1'b0;
		wr_w <= 5'b0;
		ao_w <= 32'b0;
		rd_w <= 32'b0;
	end
	else if (enable==1'b1) begin
		RegWriteW <= RegWriteM;
		MemtoRegW <= MemtoRegM;
		wr_w <= wr_m;
		ao_w <= ao_m;
		rd_w <= rd_m;
	end
end
endmodule

module FourMux(input [31:0] A, B, C, D, input [1:0] Ctrl, output [31:0] sel); //32-input 4-2 Mux.

assign sel = (Ctrl[1]==1'b1) ? ((Ctrl[0]==1'b1) ? D : C) : ((Ctrl[0]==1'b1) ? B : A);

endmodule

module OneMux(input [31:0] A, B, input Ctrl, output [31:0] sel); //32-input 2-1 Mux.

assign sel = Ctrl==1'b1 ? B : A;

endmodule

module OnMux(input [4:0] A, B, input Ctrl, output [4:0] sel); //5-input 2-1 Mux

assign sel = Ctrl==1'b1 ? B : A;

endmodule

module TwoShift(input [31:0] A, output [31:0] B); //32-bit 2-left-shift shifter

assign B = {A[29:0],2'b00};

endmodule

module SignExt(input [15:0] A, [31:0] B); //16-32 bit arithmetic extender

assign B = {{16{A[15]}},A};

endmodule

module ZeroExt(input [15:0] A, [31:0] B); //16-32 bit logical extender

assign B = {16'b0,A};

endmodule

module ZeroShift(input [15:0] A, [31:0] B); //16-32 bit logical shifter

assign B = {A,16'b0};

endmodule
