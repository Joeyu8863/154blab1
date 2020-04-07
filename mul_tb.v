
module mul_tb();
  reg[31:0]  sim_a, sim_b;
  reg sim_is_signed;
  reg sim_clk;
  reg sim_start;
  wire[63:0]  sim_y;
  mul dut(
  .a (sim_a),
  .b (sim_b),
  .clk(sim_clk),
  .start(sim_start),
  .is_signed(sim_is_signed),
  .y (sim_y));
initial

begin
  sim_a <= 32'hffffffff;
  sim_b <= 32'hffffffff;
  sim_start <= 1'b1;
  sim_clk <= 1'b0;

  forever #5 sim_clk = ~sim_clk;
  sim_is_signed <= 0;
  #100

  sim_is_signed <= 1; 
end

endmodule


