module BHT(input [31:0] f_PC, e_PC, target_address, input taken, is_branch, clk, output reg [31:0] pred_address, output reg pred_take, found);

reg [127:0] PC_cache [31:0];
reg [127:0] predict_cache [31:0];
reg [127:0] PHT [1:0];

integer i;

initial begin
	for (i = 0; i < 128; i = i + 1) begin
		PHT[i] = 2'b0;
	end
	pred_address = 32'b0;
	pred_take = 1'b0;
	found = 1'b0;
end

always @(posedge clk) begin
	if(is_branch==1'b1) begin
 		if(PC_cache[e_PC[6:0]]==e_PC) begin
			if(taken==1'b1 & PHT[e_PC[6:0]]!=2'b11) begin
				PHT[e_PC[6:0]] = PHT[e_PC[6:0]] + 1;
			end
			else if(taken==1'b0 & PHT[e_PC[6:0]]!=2'b00) begin
				PHT[e_PC[6:0]] = PHT[e_PC[6:0]] - 1;
			end
		end
		else begin
			PC_cache[e_PC[6:0]] = e_PC;
			predict_cache[e_PC[6:0]] = target_address;
			if(taken==1'b1) begin
				PHT[e_PC[6:0]] = 2'b01;
			end
		end
	end
	if(PC_cache[f_PC[6:0]]==f_PC) begin
		found = 1'b1;
		if(PHT[f_PC[6:0]]==2'b1x) begin
			pred_address = predict_cache[f_PC[6:0]];
			pred_take = 1'b1;
		end
		else begin
			pred_take = 1'b0;
		end
	end
	else begin
		found = 1'b0;
	end
end

endmodule
