//File: alu.v
//Author: Zhengzhi(Tim) Lu (Individual)

//ALU design as described in the textbook, but with 32 bits instead of 4
module alu(input [31:0] a, b, input [2:0] f, output [31:0] y, output zero);

wire [31:0] g = f[2]==1'b1 ? ~b : b;
wire [31:0] k;
wire c;

assign {c,k} = a+g+f[2];
assign y = f[1]==1'b1 ? (f[0]==1'b1 ? {31'b0,k[31]} : k) : (f[0]==1'b1 ? a|g : a&g);
assign zero = ~|y;

endmodule
