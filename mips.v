// single-cycle MIPS processor
// instantiates a controller and a datapath module

module mips(input          clk, reset,
            output  [31:0] pc,
            input   [31:0] instr,
            output         memwrite,
            output  [31:0] aluout, writedata,
            input   [31:0] readdata);

  wire        memtoreg, branch,
               pcsrc, zero,
               alusrc, regdst, regwrite, se_ze;
  wire [2:0]  alucontrol;

  controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, se_ze,
               alucontrol);
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, se_ze,
              alucontrol,
              zero, pc, instr,
              aluout, writedata, readdata);
endmodule


// Todo: Implement controller module
module controller(input   [5:0] op, funct,
                  input         zero,eq_ne,//eq new
                  output        memtoreg, memwrite,memread,// read new
                  output        alusrca,alusrcb,//new
                  output        se_ze,start_mult,mult_sign,//new
                  output        regdst, regwrite,out_branch,
                  output  [1:0] out_select,//00:aluout 01:sign extended  10: mulh 11:mull
                  output  [3:0] alucontrol);//can srca b replaced
// **PUT YOUR CODE HERE**
wire [3:0] aluop;
//maindec md(op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, aluop);
maindec md(op, funct, memtoreg, memwrite,memread, regdst, regwrite, se_ze, start_mult, mult_sign, alusrca,alusrcb,out_select,aluop);
aludec ad(funct, aluop, alucontrol);
assign out_branch = (op[0])? eq_ne & (!zero): eq_ne & zero;// when op[0] is 1, pcsrc is branch& (!zero) , when op[0] is 0 , pcsrc is branch&zero
// 00:pc+4  01:branch  10: jump
endmodule



// Todo: Implement datapath
module datapath(input          clk, reset,
                input          memtoreg, pcsrc,
                input          alusrc, regdst,
                input          regwrite, se_ze,
                input   [2:0]  alucontrol,
                output         zero,
                output  [31:0] pc,
                input   [31:0] instr,
                output  [31:0] aluout, writedata,
                input   [31:0] readdata);

// **PUT YOUR CODE HERE**                
 wire [4:0] writereg;
 wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
 wire[31:0] signimm, signimmsh;
 wire [31:0] srca, srcb;
 wire [31:0] result;
//mul in datapath
flopr #(32) pcreg(clk, reset, pcnext, pc);
adder pcadd1(pc, 32'b100, pcplus4);
sl2 immsh(signimm, signimmsh);
adder pcadd2(pcplus4, signimmsh, pcbranch);//
mux2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);//
mux2 #(32) pcmux(pcnextbr, {pcplus4[31:28],
instr[25:0], 2'b00}, se_ze, pcnext);//
// register file logic
regfile rf(clk, regwrite, instr[25:21], instr[20:16],
writereg, result, srca, writedata);
mux2 #(5) wrmux(instr[20:16], instr[15:11],
regdst, writereg);
mux2 #(32) resmux(aluout, readdata, memtoreg, result);
signext se(instr[15:0], signimm);
// ALU logic
mux2 #(32) srcbmux(writedata, signimm, alusrc, srcb);
ALU alu(srca, srcb, alucontrol, aluout, zero);//
MUL mul();
endmodule

module flopr#(parameter WIDTH = 8)
  (
  input clk,reset,
  input [WIDTH-1:0] d,
  output reg [WIDTH-1:0] q);
  
  always@(posedge clk, posedge reset)
  begin
  if(reset) q<=32'b0;
  else begin 
  q<=d;
end
end
endmodule


module mux2 #(parameter WIDTH = 8)
(input  [WIDTH-1:0] d0, d1,
input  s,
output  [WIDTH-1:0] y);
assign y = s ? d1 : d0;
endmodule


module maindec(input [5:0] op,funct,
               output  memtoreg, memwrite,memread,
               output  regdst, regwrite,
               output  se_ze,
               output  start_mult, mult_sign,
               output  alusrca,alusrcb,            
               output  [1:0] out_select,
               output  [3:0] aluop);//change 1:0 to 3:0
reg [15:0] controls;//change 8:0 to 14:0
assign {regwrite, regdst, alusrca,alusrcb,memwrite,memtoreg,memread,
 start_mult, mult_sign, se_ze, out_select, aluop} = controls;//need to adjust

always@(*)
case(op)//ADD  addiu,lui,xori,slti,sltiu,
6'b000000: begin 
case(funct)
                6'b011000: controls <= 16'b1000000110000111; //mul
                6'b011001: controls <= 16'b1000000100000111;//mulu
                6'b010000: controls <= 16'b0100000000100111;//mfhi
                6'b010010: controls <= 16'b0100000000110111;//mflo
                default:   controls <= 16'b1100000000000010; // RTYPE
endcase
end
6'b100011: controls <= 16'b1010010000000000; // LW
6'b101011: controls <= 16'b0010100000000000; // SW
6'b000100: controls <= 16'b0000000000000001; // BEQ
6'b000101: controls <= 16'b0000000000000001; // BNE
6'b001000: controls <= 16'b1010000000000000; // ADDI
6'b001001: controls <= 16'b1010000000000000; // ADDIU
6'b001010: controls <= 16'b1010000000000011; // sltI
6'b001011: controls <= 16'b1010000000001000; // sltIu
6'b001111: controls <= 16'b1010000000001001; // lui
6'b000001: controls <= 16'b1010000000001100; // xori make up op
6'b001101: controls <= 16'b1010000000000011; // ORI
6'b000010: controls <= 16'b0000000001001111; // J
default:   controls <= 16'bxxxxxxxxxxxxxxxx; // illegal op
endcase

endmodule
 
 module aludec (
 input [5:0]funct,
 input [3:0]aluop,
 output reg [3:0] alucontrol);//make it [3:0]
 
 always@(*)
 case(aluop)//mult,multu,lui,ori,xori,slti,sltiu,
   4'b0000: alucontrol <= 4'b0010; //add for lw sw addi addiu
   4'b0001: alucontrol <= 4'b1010; //sub for beq BNE
   4'b0011: alucontrol <= 4'b1011; //or for slti
   4'b1000: alucontrol <= 4'b1011; //or for sltiu
   4'b1001: alucontrol <= 4'b0001; //or for lui
   4'b1100: alucontrol <= 4'b1001; //or for xori
   default: case(funct) // r type        addu,subu,xor,sltu,
                6'b100000: alucontrol <= 4'b0010; //add
                6'b100001: alucontrol <= 4'b0010; //addu
                6'b100010: alucontrol <= 4'b1010; //sub
                6'b101011: alucontrol <= 4'b1010; //subu
                6'b100100: alucontrol <= 4'b0000; //and
                6'b100101: alucontrol <= 4'b0001; //or
                6'b101010: alucontrol <= 4'b1011; //slt
                6'b101011: alucontrol <= 4'b1011; //sltu
                6'b101111: alucontrol <= 4'b1001; //xor
                6'b111111: alucontrol <= 4'b1111; //for xnor
                default: alucontrol <= 4'bxxxx; //unknown
              endcase
            endcase
endmodule

module regfile( 
input  clk,
input  we3,
input  reset,
input  [4:0] ra1, ra2, wa3,
input  [31:0] wd3,
output  [31:0] rd1, rd2);
reg [31:0] rf[31:0];
// three ported register file
// read two ports combinationally
// write third port on rising edge of clk
// register 0 hardwired to 0
// note: for pipelined processor, write third port
// on falling edge of clk

// add reset to initial
always @(posedge clk)
if (we3) rf[wa3] <= wd3;
  
  
assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule
          
module adder(
input  [31:0] a, b,
output [31:0] y);
assign y = a + b;
endmodule
 
module sl2(
input  [31:0] a,
output  [31:0] y);
// shift left by 2
assign y = {a[29:0], 2'b00};
endmodule
 
module signext(
input  [15:0] a,
output  [31:0] y);
assign y = {{16{a[15]}}, a};
endmodule
 
module hazard(//pg420 full hazard pg427
input [4:0]rsE,rtE,rsD,rtD,
input [4:0]WriteRegM,WriteRegW,WriteRegE,
input mulfinish,
output BranchD,RegWriteE,RegWriteM, RegWriteW, flushE,MemtoRegE,MemtoRegM,stallF,stallD,ForwardAD,ForwardBD,
output reg [1:0]ForwardAE, ForwardBE);
 always @ * begin
if ((rsE != 5'b0) & (rsE== WriteRegM) & (RegWriteM == 1'b1)) //The generate if condition must be a constant expression.what's problem
                        ForwardAE <= 2'b10;//lw 
else if ((rsE != 5'b0) & (rsE== WriteRegW) & (RegWriteW == 1'b1))  
                        ForwardAE <= 2'b01; 
else 
    ForwardAE <= 2'b00;
ForwardBE <= ForwardAE;
end
assign ForwardAD = (rsD != 5'b0) &(rsD == WriteRegM) & RegWriteM;//branch pg425
assign ForwardBD = (rtD != 5'b0) & (rtD == WriteRegM) & RegWriteM;
wire branchstall = BranchD & RegWriteE & (WriteRegE == rsD | WriteRegE == rtD) | BranchD & MemtoRegM & (WriteRegM == rsD | WriteRegM == rtD);

wire lwstall=((rsD==rtE) | (rtD==rtE)) & MemtoRegE; 
assign stallF = lwstall | branchstall | ~mulfinish;
assign stallD =stallF;
assign flushE = stallD;
endmodule


module decodestage ( input [31:0] rd,
                     input [31:0] pcplus4f,
                     input clk,
                     input stalld, clear,
                     output reg[31:0] pcplus4d,
                     output reg[31:0] instrd);

always@(posedge clk, ~stalld)
begin
if(clear == 1'b0)
begin
pcplus4d <= pcplus4f;
instrd <= rd;
end

else
begin
pcplus4d <= 32'bx;// what's code for nop?
instrd <= 32'bx;
end

end
endmodule

module excutionstage (input RegWriteD,
                      input MemtoRegD,
                      input MemWriteD,MemReadD,start_multD,mult_signD,
                      input [2:0] ALUControlD,
                      input alusrcD, clk,RegDstD,
                      input FlushE,
                      output reg RegWriteE,
                      output reg MemtoRegE,
                      output reg MemWriteE,MemReadE,start_multE,mult_signE,
                      output reg [3:0] ALUControlE,
                      output reg alusrcE, RegDstE);
always@(posedge clk)
begin
if(FlushE == 1'b0)
begin
 RegWriteE <= RegWriteD;
 MemtoRegE <= MemtoRegD;
 MemWriteE <= MemWriteD;
 MemReadE <= MemReadD;
 start_multE <= start_multD;
 mult_signE <= mult_signD;
 ALUControlE <= ALUControlD;
 alusrcE <= alusrcD;
 RegDstE <= RegDstD;
end

else
assign RegWriteE = 1'b0;//clr should be 0 or x?
assign MemtoRegE = 1'b0;
assign MemWriteE = 1'b0;
assign MemReadE = 1'b0;
assign start_multE = 1'b0;
assign mult_signE = 1'b0;
assign ALUControlE = 4'b0;
assign alusrcE = 1'b0;
assign RegDstE = 1'b0;
end
endmodule

module memstage (input RegWriteE,
                 input MemtoRegE,
                 input MemWriteE,MemReadE,
                 input clk,
                 output reg RegWriteM,
                 output reg MemtoRegM,
                 output reg MemWriteM,MemReadM);
always@(posedge clk)
begin
RegWriteM <= RegWriteE;
MemtoRegM <= MemtoRegE;
MemWriteM <= MemWriteE;
MemReadM <= MemReadE;
end
endmodule

module writestage (input RegWriteM,
                   input MemtoRegM,
                   input clk,
                   output reg RegWriteW,
                   output reg MemtoRegW);
always@(posedge clk)
begin
RegWriteW <= RegWriteM;
MemtoRegW <= MemtoRegM;
end
endmodule
