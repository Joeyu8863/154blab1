// Top level system including MIPS and memories

module top(input clk, reset);

  wire [31:0] pc, instr, readdata;
  wire [31:0] writedata, dataadr;
  wire        memwrite;
  
  
  always @(negedge clk)
  begin
    if(memwrite)begin
      if(dataadr === 84 & writedata === 7)begin
        $display("Simulation succeeded");
        $stop;
      end else if(dataadr !== 80 )begin
        $display("simulation failed");
        $stop;
      end
    end
  end
  
  // processor and memories are instantiated here 
  mips mips(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);
  imem imem(pc[7:2], instr);
  dmem dmem(clk, memwrite, dataadr, writedata, readdata);

endmodule
