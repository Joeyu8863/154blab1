//Author: Zhengzhi(Tim) Lu (11/25/19)
//submodules for the datapath

module alu(input [31:0] in1, in2, input [3:0] func, output [31:0] ALUout);

wire [31:0] g = func[2]==1'b1 ? ~in2 : in2;
wire [31:0] k;
wire c;

assign {c,k} = in1+g+func[2];
assign ALUout = func[1]==1'b1 ? (func[0]==1'b1 ? {31'b0,k[31]} : k) : (func[0]==1'b1 ? in1|g : in1&g);

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

module reg_file(input [4:0] pr1, pr2, wr, input [31:0] wd, input write, clk, output [31:0] rd1, rd2); //read-and-write register file (synchronous enable)

reg [31:0] register[31:0];

integer i;

initial for (i = 0; i < 32; i = i + 1) begin
	register[i] = 32'b0; 
end

assign rd1 = register[pr1];
assign rd2 = register[pr2];

always @(posedge clk)
begin	
	if(write==1'b1) begin
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

always @(posedge clk)
begin
	if(count[6]==1'b1) begin
		count = 7'b0;
		r = 128'b0;
	end else if(start==1'b1) begin
		r[count +: 63] = r[count +: 63] + c & {64{d[count]}};
		count = count + 1;
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
