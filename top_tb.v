module top_tb();
  reg  sim_clk, sim_reset;
  
  top dut(
  .clk (sim_clk),
  .reset (sim_reset));
initial

begin
  sim_reset <= 1;
  #22
  sim_reset <= 0;
  
end
always 
begin
  sim_clk <= 1;
  #5;
  sim_clk <= 0;
  #5;
end
endmodule