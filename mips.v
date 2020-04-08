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
               alusrc, regdst, regwrite, jump;
  wire [2:0]  alucontrol;

  controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, jump,
               alucontrol);
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol,
              zero, pc, instr,
              aluout, writedata, readdata);
endmodule


// Todo: Implement controller module
module controller(input   [5:0] op, funct,
                  input         zero,eq_ne,//eq new
                  input   [1:0] pc_source,//new
                  output        memtoreg, memwrite,memread,// read new
                  output        pcsrc, alusrc,
                  output        alusrca,alusrcb,//new
                  output        se_ze,start_mult,mult_sign,//new
                  output        regdst, regwrite,
                  output        jump,
                  output  [2:0] alucontrol);//can srca b replaced

// **PUT YOUR CODE HERE**
wire [1:0] aluop;
wire branch;//eq_ne?
//maindec md(op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, aluop);
maindec md(op, pc_source, eq_ne, memtoreg, memwrite, regdst, regwrite,  se_ze, start_mult, mult_sign, aluop);
aludec ad(funct, aluop, alucontrol);
assign pcsrc = (op[0])? branch & (!zero): branch & zero;// when op[0] is 1, pcsrc is branch& (!zero) , when op[0] is 0 , pcsrc is branch&zero

endmodule



// Todo: Implement datapath
module datapath(input          clk, reset,
                input          memtoreg, pcsrc,
                input          alusrc, regdst,
                input          regwrite, jump,
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
 
flopr #(32) pcreg(clk, reset, pcnext, pc);
adder pcadd1(pc, 32'b100, pcplus4);
sl2 immsh(signimm, signimmsh);
adder pcadd2(pcplus4, signimmsh, pcbranch);//
mux2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);//
mux2 #(32) pcmux(pcnextbr, {pcplus4[31:28],
instr[25:0], 2'b00}, jump, pcnext);//
// register file logic
regfile rf(clk, regwrite, instr[25:21], instr[20:16],
writereg, result, srca, writedata);
mux2 #(5) wrmux(instr[20:16], instr[15:11],
regdst, writereg);
mux2 #(32) resmux(aluout, readdata, memtoreg, result);
signext se(instr[15:0], signimm);
// ALU logic
mux2 #(32) srcbmux(writedata, signimm, alusrc, srcb);
ALU alu(srca, srcb, clk, alucontrol, aluout, zero);//

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
//maindec md(op, pc_source, eq_ne, memtoreg, memwrite,
// regdst, regwrite,  se_ze, start_mult, mult_sign, aluop);



module maindec(input [5:0] op,
               input [1:0] pc_source,
               input   eq_ne,se_ze, start_mult, mult_sign,// do we really need start and sign
               output  memtoreg, memwrite,
               output  branch, alusrc,
               output regdst, regwrite,
               output  jump,//se_ze? and how is it work
               output  [2:0] aluop);//change 1:0 to 2:0
               reg [9:0] controls;//change 8:0 to 9:0
assign {regwrite, regdst, alusrc, branch, memwrite,
memtoreg, jump, aluop} = controls;//need to adjust

always@(*)
case(op)//ADD  addiu,lui,xori,slti,sltiu,
6'b000000: controls <= 10'b1100000010; // RTYPE
6'b100011: controls <= 10'b1010010000; // LW
6'b101011: controls <= 10'b0010100000; // SW
6'b000100: controls <= 10'b0001000001; // BEQ
6'b000101: controls <= 10'b0001000001; // BNE
6'b001000: controls <= 10'b1010000000; // ADDI
6'b001001: controls <= 10'b1010000000; // ADDIU
6'b001010: controls <= 10'b1010000011; // sltI
6'b001011: controls <= 10'b1010000100; // sltIu
6'b001111: controls <= 10'b1010000101; // lui
6'b000001: controls <= 10'b1010000110; // xori make up op
6'b001101: controls <= 10'b1010000011; // ORI
6'b000010: controls <= 10'b0000001000; // J
default: controls <= 10'bxxxxxxxxxx; // illegal op
endcase

endmodule
 
 module aludec (
 input [5:0]funct,
 input [1:0]aluop,
 output reg [3:0] alucontrol);//make it [3:0]
 
 always@(*)
 case(aluop)//mult,multu,lui,ori,xori,slti,sltiu,
   3'b000: alucontrol <= 4'b0010; //add for lw sw addi addiu
   3'b001: alucontrol <= 4'b1010; //sub for beq BNE
   3'b011: alucontrol <= 4'b1011; //or for slti
   3'b100: alucontrol <= 4'b1011; //or for sltiu
   3'b101: alucontrol <= 4'b0001; //or for lui
   3'b110: alucontrol <= 4'b1001; //or for xori
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
                6'b011000: alucontrol <= 4'b1111; //mul
                6'b011001: alucontrol <= 4'b0111;//mulu
                6'b010000: alucontrol <= 4'b0100;//mfhi
                6'b010010: alucontrol <= 4'b0101;//mflo
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
output [1:0]ForwardAE, ForwardBE);
if ((rsE != 5'b0) & (rsE== WriteRegM) & RegWriteM) //The generate if condition must be a constant expression.what's problem
                   assign      ForwardAE = 2'b10;//lw 
else if ((rsE != 5'b0) & (rsE== WriteRegW) & RegWriteW)  
                   assign      ForwardAE = 2'b01; 
else assign ForwardAE=2'b00;
assign ForwardAD = (rsD != 5'b0) &(rsD == WriteRegM) & RegWriteM;//branch pg425
assign ForwardBD = (rtD != 5'b0) & (rtD == WriteRegM) & RegWriteM;
wire branchstall = BranchD & RegWriteE & (WriteRegE == rsD | WriteRegE == rtD) | BranchD & MemtoRegM & (WriteRegM == rsD | WriteRegM == rtD);

wire lwstall=((rsD==rtE) | (rtD==rtE)) & MemtoRegE; 
assign stallF =lwstall | branchstall | ~mulfinish;
assign stallD =stallF;
assign flushE = stallD;
endmodule
