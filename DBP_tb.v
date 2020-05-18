
module DBP_tb();
reg [31:0]sim_PC;
reg [31:0]sim_targetaddress; 
reg sim_clk,sim_BranchD;
wire sim_flushbp; 
wire [31:0]sim_predicted_PC;
branch_prediction dut(
.PC(sim_PC),
.targetaddress(sim_targetaddress),
.clk(sim_clk),
.BranchD(sim_BranchD),
.flushbp(sim_flushbp),
.predicted_PC(sim_predicted_PC));

initial begin	//since register file has inverted clocking with respect to other registers, reset here must hold over both edges.
  sim_clk = 1'b0; //start with a positive duty cycle
  sim_PC = 32'h4;
  sim_targetaddress = 32'h90;
  sim_BranchD = 1'b1;
#5 sim_clk = 1'b1; 

#5  sim_clk = 1'b0; //start with a positive duty cycle
  sim_PC = 32'h4;
  sim_targetaddress = 32'h90;
  sim_BranchD = 1'b1;
#5 sim_clk = 1'b1;
#5  sim_clk = 1'b0; //start with a positive duty cycle
  sim_PC = 32'h4;
  sim_targetaddress = 32'h90;
  sim_BranchD = 1'b0;
#5 sim_clk = 1'b1;
#5  sim_clk = 1'b0; //start with a positive duty cycle
  sim_PC = 32'h4;
  sim_targetaddress = 32'h90;
  sim_BranchD = 1'b0;
#5 sim_clk = 1'b1;
#5  sim_clk = 1'b0; //start with a positive duty cycle
  sim_PC = 32'h4;
  sim_targetaddress = 32'h90;
  sim_BranchD = 1'b0;
#5 sim_clk = 1'b1;
end
endmodule
