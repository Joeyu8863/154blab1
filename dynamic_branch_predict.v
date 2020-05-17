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
a=0
b=6
loop

branch eq  a b  do
1
2a+1
3b-1
4
j loop

do
a-2
j loop
