module branch_prediction(input [31:0]PC, input clk,BranchD,output reg flushbp, output stallbp, output reg [31:0]predicted_PC);

reg [63:0]branchpc[31:0];
reg [63:0]predpc[31:0];
integer i; 	
reg [127:0]BHT[1:0];
reg prediction_state;// 11 strong preditction taken 10 weak preditction 01 weak predirction not taken 00 strong prediction not taken
assign pc_4f = PC + 32'h4;	
reg find = 1'b0;
always @(posedge clk)
for (i = 0; i < 64; i = i + 1) begin
	if(branchpc[i] == PC) //found clk 1
           begin
           predicted_PC = predpc[i];
           find = 1'b1;
           end
end
//clk2
if(find == 1'b1)
begin
if(BranchD ==1'b1)//means it's a taken branch
    begin
        flushbp = 1'b0; // Branch correctly predicted; continue execution with no stalls. 
        prediction_state = 2'b11;
//clk3
        if(BHT[i] != 2'b11)
            BHT[i] = BHT[i] + 2'b1;

    end   
//clk2 
  if(BranchD ==1'b0)//Mispredicted branch, kill fetched instruction; restart fetch at the correct target
    begin
      flushbp = 1'b1;
      prediction_state = 2'b10;
//clk3
        if(BHT[i] != 2'b0)
            BHT[i] = BHT[i] - 2'b1;
end
end

        if(find == 1'b0) //not found clk 1
           begin
           predicted_PC = pc_4f;

//clk 2
if(PC[31:25] == 6'b0 & PC[5:0] == 6'b10x) // means instructions are beq or beq
begin
  if(BranchD ==1'b1)//means it's a taken branch
    begin
        flushbp = 1'b1;
        prediction_state = 2'b01;    // what should determine the index of predpc
//this case Enter branch instruction address and next PC intobranch-target buffer. 
//Kill fetched instruction.Restart fetch at the correct target.
//clk3
        if(BHT[i] != 2'b11)
            BHT[i] = BHT[i] + 2'b1;
        

    end   
  if(BranchD ==1'b0)//normal instruction
    begin
      flushbp = 1'b0;
      prediction_state = 2'b00;
    end
end
end
end

endmodule 
mispredict and add predict	
ori $t0, $0,6
ori $t1, $0,0
ori $t2, $0,1
ori $t3, $0,4
loop:
beq $t0,$t1,do
sub $t0,$t0,$t2
add $t1,$t1,$t2
j loop
do:
beq $t0,$t3, finish
addi $t0,$t0,2
j loop
finish:
	

34080006
34090000
340a0001
340b0004
11090003
010a4022
012a4820
08000004
110b0002
21080002
08000004
correct predict		
ori $t0, $0,6
ori $t1, $0,0
ori $t2, $0,1
ori $t3, $0,4
loop:
beq $t0,$t1,do
sub $t0,$t0,$t2
add $t1,$t1,$t2
j loop
do:
j loop	

34080006
34090000
340a0001
340b0004
11090003
010a4022
012a4820
08000004
08000004
