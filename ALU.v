module ALU (input [31:0] a, b,input [3:0] f, output reg [31:0] y, output zero) ;
  wire [31:0] BB ;
  wire [31:0] S ;
  wire   cout ;
  
  assign BB = (f[3]) ? ~b : b ;
  assign {cout, S} = f[3] + a + BB ;
  always @ * begin
   case (f[2:0]) //add 1bit, addu,subu,xor,sltu,
    3'b000 : y <= a & BB ;//and /u
    3'b001 : y <= a | BB ;//or
    3'b010 : y <= S ;//add /u
    3'b011 : y <= {31'd0, S[31]};//slt /u
    3'b101 : y <= a ^ BB ;//xor
    default: y <= 32'b0;
   endcase
  end 
  
  assign zero = (y == 0) ;
   
 endmodule
