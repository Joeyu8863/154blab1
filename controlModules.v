//Author: Zhengzhi(Tim) Lu (11/25/19)

module maindec(input       clk, reset, //FSM that controls select signals for every multiprocessor cycle
               input [5:0] op,
               output      pcwrite, memwrite, irwrite, regwrite,
               output      alusrca, branch, iord, memtoreg, regdst,
               output [1:0] alusrcb, pcsrc, aluop);

reg [3:0] next; //define state variable count, output of the state variable word (combination of select signals), and the proceeding state variable next.
wire [3:0] count;
reg [14:0] word;

counter Counter(.D(next),.R(reset),.Clk(clk),.Q(count)); //define the main register for state storage

always @(count) //define the paths of FSM diagram by the current state 'count' and the current state datapath information 'op' to determine the next state 'next'
begin 
	casez({count,op})
		10'b0000??????: next = 4'b0001; //base case
		10'b000110?011: next = 4'b0010; //lw, sw
		10'b0010101011: next = 4'b0101;
		10'b0010100011: next = 4'b0011;
		10'b0011100011: next = 4'b0100;

		10'b0001000000: next = 4'b0110; //r-type
		10'b0110000000: next = 4'b0111; 
		10'b0001000100: next = 4'b1000; //branch
		10'b0001001000: next = 4'b1001; //addi
		10'b1001001000: next = 4'b1010;
		10'b0001000010: next = 4'b1011; //jump
		
		default: next = 4'b0000;	// base case: assume the decoder only accepts lab-required instructions.
	endcase
end

always @* //define the decoder (output) of the FSM
begin
	case(count)
		/*4'b0000: word = 15'b101000000010000; //NOTE: this version also works due to the fact some select signals become don't cares after the decode stage.
		4'b0001: word = 15'b000000000110000;
		4'b0010: word = 15'b000010000100000;
		4'b0011: word = 15'b000010100100000;
		4'b0100: word = 15'b000110010100000;
		4'b0101: word = 15'b010010100100000;
		4'b0110: word = 15'b000010000000010;
		4'b0111: word = 15'b000110001000010;
		4'b1000: word = 15'b000011000000101;
		4'b1001: word = 15'b000010000100000;
		4'b1010: word = 15'b000110000100000;
		4'b1011: word = 15'b100000000001000;
		default: word = 15'b101000000010000; */

		4'b0000: word = 15'b101000000010000; //This version of select signals matches the lab chart. State-0 output: base case.
		4'b0001: word = 15'b000000000110000; //State-1 to...
		4'b0010: word = 15'b000010000100000;
		4'b0011: word = 15'b000000100000000;
		4'b0100: word = 15'b000100010000000;
		4'b0101: word = 15'b010000100000000;
		4'b0110: word = 15'b000010000000010;
		4'b0111: word = 15'b000100001000000;
		4'b1000: word = 15'b000011000000101;
		4'b1001: word = 15'b000010000100000;
		4'b1010: word = 15'b000100000000000;
		4'b1011: word = 15'b100000000001000; //...11 outputs.
		default: word = 15'b101000000010000; //base case. Assume no other states are valid.
	endcase
end

assign {pcwrite, memwrite, irwrite, regwrite, alusrca, branch, iord, memtoreg, regdst, alusrcb, pcsrc, aluop} = word; //distribute output to appropriate destinations.

endmodule

module aludec(input [5:0] funct, input [1:0] aluop, output reg [2:0] alucontrol); // aludec defines the control signal for the ALU depending on the state, alu op, and funct.

always @*
begin
	casez({aluop,funct})
		8'b00??????: alucontrol = 3'b010; //not R-type.
		8'b?1??????: alucontrol = 3'b110;
		8'b1?100000: alucontrol = 3'b010; //R-type.
		8'b1?100010: alucontrol = 3'b110;
		8'b1?100100: alucontrol = 3'b000;
		8'b1?100101: alucontrol = 3'b001;
		8'b1?101010: alucontrol = 3'b111;
	endcase
end

endmodule

module counter(input [3:0] D, input R, Clk, output reg [3:0] Q); //the register for FSM, same structure as the flipflop.

always @(posedge Clk)
begin
	if(R==1'b1) begin
		Q <= 4'b0;
	end else begin
		Q <= D;
	end
end

endmodule
