
module shifter(input sign,
               input [63:0]sin,
               output [63:0]q);

assign q = (sign)?{sin[63],sin[61:0],1'b0}:(sin<<1);//for keep sign/unsign
//q = {sin[62:0],1'b0};

endmodule

