//static branch prediction ??always not taken
module branch_prediction(input PCbranch, output predicted PC)
assign predicted PC = PCbranch; //since it's always not taken branch predictor
//it will fetch every instruction untill processor confirm this branch will happen
// then flush next instruction which works as orginal pipeline processor.
endmodule 