module datapath (input clock, reset);

wire [31:0] pc_j, pc_f, p_c, p_pc, pc_4f, pc_4d, pc_bd, sign_id, sign_idk, zero_id, r_w, e_1, e_2, eq_1, eq_2, pc_deq, pc_dne;
wire [31:0] inst, inst_d, sign_ie, zero_ie;
wire [31:0] eq_e1, eq_e2, src_ae, wd_e, src_be, ao_e, ao_m, alu_e, ao_w, wd_m, rd_m, rd_w;
wire [31:0] m_hi, m_lo, m_stall, o_e;
wire [4:0] rs_d, rt_d, rd_d, rs_e, rt_e, rd_e, wr_e, wr_m, wr_w;
wire eq_r;

wire m_g, m_w, r_dst, r_wd, jump, b_eq, b_nq, start_mult, mult_sign;
wire m_ge, m_we, r_dste, r_we, start_multe, mult_signe;
wire r_wm, m_gm, m_rm, r_ww, m_gw;
wire [1:0] alusrc, out_select, alusrc_e, out_select_e;
wire [3:0] aluop, aluop_e;

wire [1:0] f_ae, f_be; 
wire f_ad, f_bd, f_e, s_m, s_e, s_d, s_f, s_w;

writestage w_stage(.RegWriteM(r_wm),.MemtoRegM(m_rm),.clk(clock),.enable(~s_w),.reset(reset),.wr_m(wr_m),.wr_w(wr_w),
		   .RegWriteW(r_ww),.MemtoRegW(m_gw),.ao_m(ao_m),.rd_m(rd_m),.ao_w(ao_w),.rd_w(rd_w));

memstage m_stage(.RegWriteE(r_we),.MemtoRegE(m_ge),.MemWriteE(m_we),.clk(clock),.enable(~s_m),.wd_m(wd_m),.ao_m(ao_m),.wd_e(wd_e),.o_e(o_e),
		 .reset(reset),.wr_e(wr_e),.wr_m(wr_m),.RegWriteM(r_wm),.MemtoRegM(m_gm),.MemWriteM(m_rm));

executionstage e_stage(.RegWriteD(r_wd),.MemtoRegD(m_g),.MemWriteD(m_w),.start_multD(start_mult),.mult_signD(mult_sign),.ALUControlD(aluop),.outSelectD(out_select),
	       .RsD(rs_d),.RtD(rt_d),.RdD(rd_d),.s_id(sign_id),.z_id(zero_id),.alusrcD(alusrc),.clk(clock),.reset(reset),.RegDstD(r_dst),.FlushE(f_e),
	       .enable(~s_e),.s_ie(sign_ie),.z_ie(zero_ie),.RegWriteE(r_we),.MemtoRegE(m_ge),.MemWriteE(m_we),.start_multE(start_multe),.mult_signE(mult_signe),
	       .RsE(rs_e),.RtE(rt_e),.RdE(rd_e),.ALUControlE(aluop_e),.outSelectE(out_select_e),.alusrcE(alusrc_e),.RegDstE(r_dste),.r_d1(eq_1),.r_d2(eq_2),.r_e1(eq_e1),.r_e2(eq_e2));

decodestage d_stage(.instr(inst),.pcplus4f(pc_4f),.clk(clock),.reset(reset),.enable(~s_d),.clear((pc_deq|pc_dne|jump)),.pcplus4d(pc_4d),.instrd(inst_d));

register i_stage(.D(p_pc),.R(reset),.Clk(clock),.En(~s_f),.Q(pc_f));
inst_memory imem(.address(pc_f[7:2]),.read_data(inst));

hazard Hazard(.rsE(rs_e),.rtE(rt_e),.rsD(rs_d),.rtD(rt_d),.WriteRegM(wr_m),.WriteRegW(wr_w),.WriteRegE(wr_e),.multstall(m_stall),.BranchD((b_eq|b_ne)),
	       .RegWriteE(r_we),.RegWriteM(r_wm),.RegWriteW(r_ww),.flushE(f_e),.MemtoRegE(m_ge),.MemtoRegM(m_gm),.stallF(s_f),.stallD(s_d),.stallE(s_e),
	       .stallM(s_m),.stallW(s_w),.ForwardAD(f_ad),.ForwardBD(f_bd),.ForwardAE(f_ae),.ForwardBE(f_be));

controller control(.op(inst_d[31:26]),.funct(inst_d[5:0]),.memtoreg(m_g),.memwrite(m_w),.regdst(r_dst),.regwrite(r_wd),.jump(jump),
		   .b_eq(b_eq),.b_nq(b_nq),.start_mult(start_mult),.mult_sign(mult_sign),.alusrc(alusrc),.out_select(out_select),.aluop(aluop));

reg_file Register(.pr1(inst_d[25:21]),.pr2(inst_d[20:16]),.wr(r_w),.wd(w_rw),.write(r_ww),.clk(clock),.reset(reset),.rd1(e_1),.rd2(e_2));

data_memory dmem(.clk(clock),.write(m_rm),.address(ao_m),.write_data(wd_m),.read_data(rd_m));

FourMux output_e(.A(ao_e),.B({zero_ie[15:0],16'b0}),.C(m_hi),.D(m_lo),.Ctrl(out_select_e),.sel(o_e));
ALU alunit(.a(src_ae),.b(src_be),.f(aluop_e),.y(ao_e));
FourMux out_srcb(.A(wd_e),.B(sign_ie),.C(zero_ie),.D(32'b0),.Ctrl(wd_e),.sel(src_be));
FourMux mux_ra(.A(eq_e1),.B(r_w),.C(ao_m),.D(32'b0),.Ctrl(f_ae),.sel(src_ba));
FourMux mux_rb(.A(eq_e2),.B(r_w),.C(ao_m),.D(32'b0),.Ctrl(f_be),.sel(wd_e));
SignExt sign_imm(.A(inst_d[15:0]),.B(sign_id));
ZeroExt zero_imm(.A(inst_d[15:0]),.B(zero_id));
TwoShift(.A(sign_id),.B(sign_idk));

assign r_w = m_gw==1'b1 ? rd_w : ao_w;
assign wr_e = r_dste==1'b1 ? rt_e : rd_e;
assign rs_d = inst_d[25:21];
assign rt_d = inst_d[20:16];
assign rd_d = inst_d[15:11];
assign eq_1 = f_ad==1'b1 ? e_1 : ao_m;
assign eq_2 = f_bd==1'b1 ? e_2 : ao_m;
assign eq_r = eq_1==eq_2;
assign pc_deq = eq_r & b_eq;
assign pc_dne = ~eq_r & b_ne;
assign pc_bd = sign_idk + pc_4d;
assign pc_4f = pc_f + 32'h4;
assign p_c = (pc_deq|pc_dne)==1'b1 ? pc_bd : pc_4f;
assign pc_j = {pc_4d[31:28], inst_d[25:0],2'b00};
assign p_pc = jump==1'b1 ? pc_j : p_c;

endmodule
