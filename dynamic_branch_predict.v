module branch_prediction(input [31:0]PC, input [31:0]targetaddress, input clk,BranchD,output reg flushbp, output reg [31:0]predicted_PC);

reg [31:0]branchpc[127:0];
reg [31:0]predpc[127:0];
reg [1:0]predictionbit[127:0];
integer i; 	
reg [1:0]BHT[127:0];
reg prediction_state;// 11 strong preditction taken 10 weak preditction 01 weak predirction not taken 00 strong prediction not taken
reg find = 1'b0;
initial 
begin
for (i = 0; i < 128; i = i + 1) begin
         predictionbit[i]=2'b0;
    end
end


always @(posedge clk)
begin
	if(branchpc[PC[6:0]] == PC && predictionbit[PC[6:0]][1] ==1'b1) //found clk 1
           begin
           predicted_PC = predpc[PC[6:0]];
           find = 1'b1;
           end
        else begin
           find = 1'b0;
        end

//clk2
if(find == 1'b1)
begin
if(BranchD ==1'b1)//means it's a taken branch
    begin
        flushbp = 1'b0; // Branch correctly predicted; continue execution with no stalls. 
       // prediction_state = 2'b11;
//clk3
        if(predictionbit[PC[6:0]] != 2'b11)
            predictionbit[PC[6:0]] = predictionbit[PC[6:0]] + 2'b1;

    end   
//clk2 
  if(BranchD ==1'b0)//Mispredicted branch, kill fetched instruction; restart fetch at the correct target
    begin
      flushbp = 1'b1;
   //   prediction_state = 2'b10;
//clk3
        if(predictionbit[PC[6:0]] != 2'b0)
            predictionbit[PC[6:0]] = predictionbit[PC[6:0]] - 2'b1;
    end
end

if(find == 1'b0) //not found clk 1
    begin
      predicted_PC = PC + 32'h4;

//clk 2

           if(BranchD ==1'b1)//means it's a taken branch
               begin
                 flushbp = 1'b1;
                 prediction_state = 2'b01;    // what should determine the index of predpc
                 predpc[PC[6:0]] = targetaddress;
                 branchpc[PC[6:0]] = PC;
                 predictionbit[PC[6:0]] = 2'b1;
//this case Enter branch instruction address and next PC intobranch-target buffer. 
//Kill fetched instruction.Restart fetch at the correct target.
//clk3
               if(predictionbit[PC[6:0]] != 2'b11)
                   predictionbit[PC[6:0]] = predictionbit[PC[6:0]] + 2'b1;
        

               end   
          if(BranchD ==1'b0)//normal instruction
               begin
                 flushbp = 1'b0;
                 prediction_state = 2'b00;
                 predpc[PC[6:0]] = targetaddress;
                 branchpc[PC[6:0]] = PC;
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
