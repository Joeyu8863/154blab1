
module branch_predictionIF(input [31:0]PC, input clk,BranchD,output flushbp,prediction_state, output stallbp, output [31:0]predicted_PC)

reg [63:0]branchpc[31:0];
reg [63:0]predpc[31:0];
reg prediction_state;// 11 strong preditction taken 10 weak preditction 01 weak predirction not taken 00 strong prediction not taken
always @(posedge clk)
for (i = 0; i < 64; i = i + 1) begin
	if(branchpc[i] == PC); //found
           begin
           prediction_state[i] = 1'b1;
           predicted_PC = predpc[i];
           end
        else //not found
           begin
           predicted_PC = PC+32'h4;
           prediction_state[i] = 1'b0;
           end
	end

endmodule 


module branch_predictionID(input [31:0]PC, input clk,i,output flushbp, output stallbp, output [31:0]predicted_PC)

reg [63:0]branchpc[31:0];
reg [63:0]predpc[31:0];
reg [1:0]prediction_state;// 11 strong preditction taken 10 weak preditction 01 weak predirction not taken 00 strong prediction not taken
always @(posedge clk)
if(i ==1'b0) //not found
begin
if(PC[31:25] == 6'b0 & PC[5:0] == 6'b10x) // means instructions are beq or beq
begin
  if(BranchD ==1'b1)//means it's a taken branch
    begin
        flushbp = 1'b1;
        prediction_state[i] = 2'b01;    // what should determine the index of predpc
//this case Enter branch instruction address and next PC intobranch-target buffer. 
//Kill fetched instruction.Restart fetch at the correct target.
    end   
  if(BranchD ==1'b0)//normal instruction
    begin
      flushbp = 1'b0;
      prediction_state[i] = 2'b00;
    end
end
end
if(i ==1'b1) //found
if(BranchD ==1'b1)//means it's a taken branch
    begin
         flushbp = 1'b0; // Branch correctly predicted; continue execution with no stalls. 
        prediction_state[i] = 2'b11;
    end   
  if(BranchD ==1'b0)//Mispredicted branch, kill fetched instruction; restart fetch at the correct target
    begin
      flushbp = 1'b1;
      prediction_state[i] = 2'b10;
    end
end
endmodule 