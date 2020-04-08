module ALU (input [31:0] a, b, input clk, input [3:0] f, output reg [31:0] y, output zero) ;
  wire [31:0] BB ;
  wire [31:0] S ;
  wire   cout ;
  
  assign BB = (f[3]) ? ~b : b ;
  assign {cout, S} = f[3] + a + BB ;
  wire mulfinish;
  wire [63:0] mulout;
  wire [31:0] mulh;
  wire [31:0] mull;
  assign {mulh,mull} = mulout;
  always @ * begin
   case (f[2:0]) //add 1bit, addu,subu,xor,sltu,
    3'b000 : y <= a & BB ;//and /u
    3'b001 : y <= a | BB ;//or
    3'b010 : y <= S ;//add /u
    3'b011 : y <= {31'd0, S[31]};//slt /u
    3'b001 : y <= a ^ BB ;//xor
    3'b111 : begin mul(a,b,clk,1'b1,f[3],mulfinish,mulout);//mul/u
             y <= 32'b0;//since mul or mulu do not need to have a result, I just give a 0
             end
    3'b100 : y <= mulh; //mfhi
    3'b101 : y <= mull; //mflo
   endcase
  end 
  
  assign zero = (y == 0) ;
   
 endmodule
