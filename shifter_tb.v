
module shifter_tb();
  reg sim_sign;
  reg[63:0]  sim_sin;
  wire[63:0] sim_q;
  wire[63:0] sim_sign_q;
  shifter dut(
  .sign(sim_sign),
  .sin(sim_sin),
  .q(sim_q),
  .sign_q(sim_sign_q));


initial
begin
sim_sign<=1'b1;
sim_sin<=64'hbfffffffffffffff;


end

endmodule

