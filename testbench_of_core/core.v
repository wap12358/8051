module core(
    clk, rst,
    rom_addr, rom_data,
    ram_rd_addr, ram_rd_data, ram_rd_vld, data_rd_en, xdata_rd_en,
    ram_wr_addr, ram_wr_data, data_wr_en, xdata_wr_en
);






// define port ***********************************************/
// basic signal
input				clk;
input				rst;

// rom
output	[15: 0]		rom_addr;
input	[ 7: 0]		rom_data;

// ram
// read
output   [15: 0]  ram_rd_addr;
input    [ 7: 0]  ram_rd_data;
input             ram_rd_vld;

output            data_rd_en;
output            xdata_rd_en;

// write
output   [15: 0]  ram_wr_addr;
output   [ 7: 0]  ram_wr_data;

output            data_wr_en;
output            xdata_wr_en;

// end of define port ****************************************/ 






// define instruction ****************************************/
`include "instruction.sv"
// end of define instruction *********************************/ 






// define wire & reg *****************************************/

// enable signal
wire				work_en;
reg					ram_wait;



// length of command
//wire				length1;
wire				length2f;
wire				length2;
wire				length3;



// pipeline
wire	[ 7: 0]		pipeline0;
reg		[ 7: 0]		pipeline1;
reg		[ 7: 0]		pipeline2;
reg		[ 3: 0]		command_flag;
wire	[ 7: 0]		pipeline0_cmd;
wire	[ 7: 0]		pipeline1_cmd;
wire	[ 7: 0]		pipeline2_cmd;



// important register
reg		[ 7: 0]		acc;
reg		[ 7: 0]		b;
wire	[ 7: 0]		psw;
reg		[ 7: 0]		sp;
reg					psw_cy;
reg					psw_ac;
reg					psw_f0;
reg					psw_rs1;
reg					psw_rs0;
reg					psw_ov;
reg					psw_user;
wire				psw_p;

wire	[ 7:0]      sp_sub1;
wire	[ 7:0]      sp_add1;

assign psw = {psw_cy, psw_ac, psw_f0, psw_rs1, psw_rs0, psw_ov, psw_user, psw_p};



// pc & get command
reg					pc_en;
reg		[15: 0]		rom_addr;
reg		[15: 0]		pc;
reg		[15: 0]		dp;
wire	[15: 0]		pc_add1;
wire	[15: 0]		rom_code_base;
wire	[15: 0]		rom_code_rel;
wire	[15: 0]		rom_code_addr;

// ram
wire				data_rd_en_buf;
wire				xdata_rd_en_buf;
reg		[ 7: 0]		ram_rd_data_0;
reg		[ 7: 0]		ram_rd_data_1;
reg	    [15: 0]	    ram_rd_addr_buf;

wire				data_wr_en_buf;
wire				xdata_wr_en_buf;
reg	    [ 7: 0]	    ram_wr_data_buf;

wire				data_same;
wire				xdata_same;
reg					same_flag;
reg		[ 7: 0]		same_byte;

wire				data_rd_internal;
wire				data_wr_internal;

wire				use_psw;
wire				wr_psw;
wire				use_dp;
wire				wr_dp;
wire				use_acc;
wire				wr_acc;
wire				use_sp;
wire				wr_sp;
wire				wait_en;

reg		[ 7: 0]		ram_wr_data_bit_operate;
reg		[15: 0]		ram_wr_addr_buf;



// ACC & ALU
wire    [ 3:0]      low;
wire    [ 3:0]      high;
wire                bit_high; 
wire    [ 7:0]      add_byte;

wire                psw_ac_buf;
wire                psw_cy_buf;
wire                psw_ov_buf;

wire	[15: 0]	    acc_mult;
wire	[ 7: 0]	    acc_div_rem;
wire	[ 7: 0]	    acc_div_ans;
wire	[ 7: 0]	    acc_and;
wire	[ 7: 0]	    acc_or;
wire	[ 7: 0]	    acc_xor;

reg     [ 7: 0]	    add_a;
reg     [ 7: 0]	    add_b;
reg     		    add_c;
reg     		    sub_flag;

wire    [ 3: 0]     da_low;
wire    [ 3: 0]     da_high;

// end of define wire & reg **********************************/ 






// length of command ****************************************/
//assign	length1	= add_a_rn(pipeline0)|addc_a_rn(pipeline0)|subb_a_rn(pipeline0)|inc_a(pipeline0)|inc_rn(pipeline0)|inc_dp(pipeline0)|dec_a(pipeline0)|dec_rn(pipeline0)|mul(pipeline0)|div(pipeline0)|da(pipeline0)|anl_a_rn(pipeline0)|orl_a_rn(pipeline0)|xrl_a_rn(pipeline0)|clr_a(pipeline0)|cpl_a(pipeline0)|rl(pipeline0)|rlc(pipeline0)|rr(pipeline0)|rrc(pipeline0)|swap(pipeline0)|mov_a_rn(pipeline0)|mov_rn_a(pipeline0)|mov_ri_a(pipeline0)|movx_a_dp(pipeline0)|movx_ri_a(pipeline0)|movx_dp_a(pipeline0)|xch_a_rn(pipeline0)|clr_c(pipeline0)|setb_c(pipeline0)|cpl_c(pipeline0)|jmp(pipeline0);
assign	length2f	= add_a_ri(pipeline0)|addc_a_ri(pipeline0)|subb_a_ri(pipeline0)|inc_ri(pipeline0)|dec_ri(pipeline0)|anl_a_ri(pipeline0)|orl_a_ri(pipeline0)|xrl_a_ri(pipeline0)|mov_a_ri(pipeline0)|movc_a_dp(pipeline0)|movc_a_pc(pipeline0)|movx_a_ri(pipeline0)|xch_a_ri(pipeline0)|xchd(pipeline0);
assign	length2		= add_a_di(pipeline0)|add_a_da(pipeline0)|addc_a_di(pipeline0)|addc_a_da(pipeline0)|subb_a_di(pipeline0)|subb_a_da(pipeline0)|inc_di(pipeline0)|dec_di(pipeline0)|anl_a_di(pipeline0)|anl_a_da(pipeline0)|anl_di_a(pipeline0)|orl_a_di(pipeline0)|orl_a_da(pipeline0)|orl_di_a(pipeline0)|xrl_a_di(pipeline0)|xrl_a_da(pipeline0)|xrl_di_a(pipeline0)|mov_a_di(pipeline0)|mov_a_da(pipeline0)|mov_rn_di(pipeline0)|mov_rn_da(pipeline0)|mov_di_a(pipeline0)|mov_di_rn(pipeline0)|mov_di_ri(pipeline0)|mov_ri_di(pipeline0)|mov_ri_da(pipeline0)|push(pipeline0)|pop(pipeline0)|xch_a_di(pipeline0)|clr_bit(pipeline0)|setb_bit(pipeline0)|cpl_bit(pipeline0)|anl_c_bit(pipeline0)|anl_c_nbit(pipeline0)|orl_c_bit(pipeline0)|orl_c_nbit(pipeline0)|mov_c_bit(pipeline0)|mov_bit_c(pipeline0)|jc(pipeline0)|jnc(pipeline0)|ajmp(pipeline0)|sjmp(pipeline0)|jz(pipeline0)|jnz(pipeline0)|djnz_rn_rel(pipeline0);
assign	length3		= anl_di_da(pipeline0)|orl_di_da(pipeline0)|xrl_di_da(pipeline0)|mov_di_di(pipeline0)|mov_di_da(pipeline0)|mov_dp_da(pipeline0)|jb(pipeline0)|jnb(pipeline0)|jbc(pipeline0)|acall(pipeline0)|lcall(pipeline0)|ret(pipeline0)|reti(pipeline0)|ljmp(pipeline0)|cjne_a_di_rel(pipeline0)|cjne_a_da_rel(pipeline0)|cjne_rn_da_rel(pipeline0)|cjne_ri_da_rel(pipeline0)|djnz_di_rel(pipeline0);
// end of length of command *********************************/






// enable signal ********************************************/

assign	work_en = ~(ram_wait & ~ram_rd_vld);

// ram_wait
always @(posedge clk or negedge rst) begin
if (~rst) begin
	ram_wait <= 1'b0;
end else if (work_en) begin
	if (data_rd_en|xdata_rd_en) begin
		ram_wait <= 1'b1;
	end else if (ram_rd_vld) begin
		ram_wait <= 1'b0;
	end
end
end

// end of enable signal *************************************/






// pipeline *************************************************/

assign pipeline0 = rom_data;

assign pipeline0_cmd = command_flag[1] ? pipeline0 : 8'h00;
assign pipeline1_cmd = command_flag[2] ? pipeline1 : 8'h00;
assign pipeline2_cmd = command_flag[3] ? pipeline2 : 8'h00;

always @(posedge clk or negedge rst) begin
if (~rst) begin
		pipeline1 <= 8'h00;
		pipeline2 <= 8'h00;
	end
else if (work_en) begin
		pipeline1 <= pipeline0;
		pipeline2 <= pipeline1;
	end
end

always @(posedge clk or negedge rst) begin
if (~rst) begin
		command_flag <= 4'b0001;
	end
else if (work_en) begin
		if (wait_en) begin
			command_flag <= {2'b0, command_flag[1:0]};
		end
		else if (command_flag[1]) begin
			if (length2|length2f) begin
				command_flag <= {command_flag[2],3'b101};
			end else if (length3) begin
				command_flag <= {command_flag[2],3'b100};
			end else begin
				command_flag <= {command_flag[2:0],1'b1};
			end
		end else begin
			command_flag <= {command_flag[2:0],1'b1};
		end
end
end

// end of pipeline ******************************************/






// pc & get command *****************************************/

always @*
if (~work_en) begin
    pc_en = 1'b0;
end else if (wait_en|(length2f & command_flag[1])) begin
    pc_en = 1'b0;
end else begin
    pc_en = 1'b1;
end 

always @(posedge clk or negedge rst) begin
	if (~rst) begin
		pc <= 16'h0000;
	end else if (pc_en) begin 
		pc <= pc_add1;
	end else begin
		pc <= pc;
	end
end

assign pc_add1 = rom_addr + 1'b1;

assign rom_code_base	= (movc_a_dp(pipeline0_cmd)|jmp(pipeline0_cmd)) ? dp : pc;
assign rom_code_rel		= (jc(pipeline1_cmd)||jnc(pipeline1_cmd)|jb(pipeline2_cmd)|jnb(pipeline2_cmd)|jbc(pipeline2_cmd)|sjmp(pipeline1_cmd)|jz(pipeline1_cmd)|jnz(pipeline1_cmd)|cjne_a_di_rel(pipeline2_cmd)|cjne_a_da_rel(pipeline2_cmd)|cjne_rn_da_rel(pipeline2_cmd)|cjne_ri_da_rel(pipeline2_cmd)|djnz_rn_rel(pipeline1_cmd)|djnz_di_rel(pipeline2_cmd)) ? {{8{pipeline0[7]}},pipeline0} : {{8{acc[7]}},acc};	
assign rom_code_addr	= rom_code_base + rom_code_rel;

always @* begin
	if (acall(pipeline1_cmd)) begin
	    rom_addr = {pc[15:11],pipeline1[7:5],pipeline0};
	end else if (lcall(pipeline2_cmd)|ljmp(pipeline2_cmd)) begin
	    rom_addr = {pipeline1,pipeline0};	
	end else if (ret(pipeline2_cmd)|reti(pipeline2_cmd)) begin
	    rom_addr = {ram_rd_data_1,ram_rd_data_0};
	end else if (ajmp(pipeline1_cmd)) begin
	    rom_addr = {pc[15:11],pipeline1[7:5],pipeline0};	
	end else if (movc_a_dp(pipeline0_cmd)|movc_a_pc(pipeline0_cmd)|(jc(pipeline1_cmd) & psw_cy)|(jnc(pipeline1_cmd) & ~psw_cy)|((jb(pipeline2_cmd)|jbc(pipeline2_cmd)	) & ram_rd_data_0[pipeline1[2:0]])|(jnb(pipeline2_cmd) & ~ram_rd_data_0[pipeline1[2:0]])|sjmp(pipeline1_cmd)|jmp(pipeline0_cmd)|(jz(pipeline1_cmd) & (acc==8'b0))|(jnz	(pipeline1_cmd) & (acc!=8'b0))|(cjne_a_di_rel(pipeline2_cmd) & (acc!=ram_rd_data_0))|(cjne_a_da_rel(pipeline2_cmd) & (acc!=pipeline1))|	(cjne_rn_da_rel(pipeline2_cmd) & (ram_rd_data_1!=pipeline1))|(cjne_ri_da_rel(pipeline2_cmd) & (ram_rd_data_0!=pipeline1))|((djnz_rn_rel(pipeline1_cmd)||	djnz_di_rel(pipeline2_cmd)) & (ram_rd_data_0!=8'h1))) begin
	    rom_addr = rom_code_addr; 
	end else begin
	    rom_addr = pc;
	end 
end 

// end of pc & get command **********************************/






// read ram *************************************************/

assign	data_rd_en_buf	= (//ARITHMETIC OPERATIONS
	add_a_rn(pipeline0_cmd)|add_a_di(pipeline1_cmd)|add_a_ri(pipeline0_cmd)|add_a_ri(pipeline1_cmd)| //add
	addc_a_rn(pipeline0_cmd)|addc_a_di(pipeline1_cmd)|addc_a_ri(pipeline0_cmd)|addc_a_ri(pipeline1_cmd)| //addc
	subb_a_rn(pipeline0_cmd)|subb_a_di(pipeline1_cmd)|subb_a_ri(pipeline0_cmd)|subb_a_ri(pipeline1_cmd)| //subb
	inc_rn(pipeline0_cmd)|inc_di(pipeline1_cmd)|inc_ri(pipeline0_cmd)|inc_ri(pipeline1_cmd)| //inc
	dec_rn(pipeline0_cmd)|dec_di(pipeline1_cmd)|dec_ri(pipeline0_cmd)|dec_ri(pipeline1_cmd))| //dec
	(//LOGICAL OPERATIONS
	anl_a_rn(pipeline0_cmd)|anl_a_di(pipeline1_cmd)|anl_a_ri(pipeline0_cmd)|anl_di_a(pipeline1_cmd)|anl_di_da(pipeline1_cmd)|anl_a_ri(pipeline1_cmd)| //anl
	orl_a_rn(pipeline0_cmd)|orl_a_di(pipeline1_cmd)|orl_a_ri(pipeline0_cmd)|orl_di_a(pipeline1_cmd)|orl_di_da(pipeline1_cmd)|orl_a_ri(pipeline1_cmd)| //orl
	xrl_a_rn(pipeline0_cmd)|xrl_a_di(pipeline1_cmd)|xrl_a_ri(pipeline0_cmd)|xrl_di_a(pipeline1_cmd)|xrl_di_da(pipeline1_cmd)|xrl_a_ri(pipeline1_cmd))| //xrl
	(//DATA TRANSFER
	mov_a_rn(pipeline0_cmd)|mov_a_di(pipeline1_cmd)|mov_a_ri(pipeline0_cmd)|mov_rn_di(pipeline1_cmd)|mov_di_rn(pipeline0_cmd)|mov_di_di(pipeline1_cmd)|mov_di_ri(pipeline0_cmd)|mov_ri_a(pipeline0_cmd)|mov_ri_di(pipeline0_cmd)|mov_ri_di(pipeline1_cmd)|mov_ri_da(pipeline0_cmd)|mov_a_ri(pipeline1_cmd)|mov_di_ri(pipeline1_cmd)| //mov
	movx_a_ri(pipeline0_cmd)|movx_ri_a(pipeline0_cmd)| //movx
	push(pipeline1_cmd)|pop(pipeline0_cmd)| //push & pop
	xch_a_rn(pipeline0_cmd)|xch_a_di(pipeline1_cmd)|xch_a_ri(pipeline0_cmd)|xch_a_ri(pipeline1_cmd)| //xch
	xchd(pipeline0_cmd))|xchd(pipeline1_cmd)| //xchd
	(//BOOLEAN VARIABLE MANIPULATION
	clr_bit(pipeline1_cmd)|setb_bit(pipeline1_cmd)|cpl_bit(pipeline1_cmd)|anl_c_bit(pipeline1_cmd)|anl_c_nbit(pipeline1_cmd)|orl_c_bit(pipeline1_cmd)|orl_c_nbit(pipeline1_cmd)|mov_c_bit(pipeline1_cmd)|mov_bit_c(pipeline1_cmd)|jb(pipeline1_cmd)|jnb(pipeline1_cmd)|jbc(pipeline1_cmd))|
	(//PROGRAM BRANCHING
	cjne_a_di_rel(pipeline1_cmd)|cjne_rn_da_rel(pipeline0_cmd)|cjne_ri_da_rel(pipeline0_cmd)|djnz_rn_rel(pipeline0_cmd)|djnz_di_rel(pipeline1_cmd)|cjne_ri_da_rel(pipeline1_cmd)|ret(pipeline0_cmd)|ret(pipeline1_cmd)|reti(pipeline0_cmd)|reti(pipeline1_cmd)
	);

assign	xdata_rd_en_buf	= movx_a_ri(pipeline1_cmd)|movx_a_dp(pipeline0_cmd);

assign	data_same	= data_wr_en & (ram_rd_addr[7:0]==ram_wr_addr[7:0]);// data_rd_en &
assign	xdata_same	= xdata_rd_en & xdata_wr_en & ram_rd_addr==ram_wr_addr;
assign	data_rd_internal = ((ram_rd_addr[7:0]==8'he0)|(ram_rd_addr[7:0]==8'hd0)|(ram_rd_addr[7:0]==8'h83)|(ram_rd_addr[7:0]==8'h82)|(ram_rd_addr[7:0]==8'h81)|(ram_rd_addr[7:0]==8'hf0));//data_rd_en &

assign	data_rd_en	= work_en & data_rd_en_buf & ~data_same & ~wait_en;
assign	xdata_rd_en	= work_en & xdata_rd_en_buf & ~xdata_same & ~wait_en;

assign	ram_rd_addr = ram_rd_addr_buf;
always @*
if (~rst) begin
	ram_rd_addr_buf = 16'h00;
end else if (add_a_rn(pipeline0_cmd)|addc_a_rn(pipeline0_cmd)|subb_a_rn(pipeline0_cmd)|inc_rn(pipeline0_cmd)|dec_rn(pipeline0_cmd)|anl_a_rn(pipeline0_cmd)|orl_a_rn(pipeline0_cmd)|xrl_a_rn(pipeline0_cmd)|mov_a_rn(pipeline0_cmd)|mov_di_rn(pipeline0_cmd)|xch_a_rn(pipeline0_cmd)|cjne_rn_da_rel(pipeline0_cmd)|djnz_rn_rel(pipeline0_cmd)) begin
    ram_rd_addr_buf = { 11'h00, psw_rs1, psw_rs0, pipeline0_cmd[2:0] };
end else if (add_a_di(pipeline1_cmd)|addc_a_di(pipeline1_cmd)|subb_a_di(pipeline1_cmd)|inc_di(pipeline1_cmd)|dec_di(pipeline1_cmd)|anl_a_di(pipeline1_cmd)|anl_di_a(pipeline1_cmd)|anl_di_da(pipeline1_cmd)|orl_a_di(pipeline1_cmd)|orl_di_a(pipeline1_cmd)|orl_di_da(pipeline1_cmd)|xrl_a_di(pipeline1_cmd)|xrl_di_a(pipeline1_cmd)|xrl_di_da(pipeline1_cmd)|mov_a_di(pipeline1_cmd)|mov_rn_di(pipeline1_cmd)|mov_di_di(pipeline1_cmd)|mov_ri_di(pipeline1_cmd)|push(pipeline1_cmd)|xch_a_di(pipeline1_cmd)|cjne_a_di_rel(pipeline1_cmd)|djnz_di_rel(pipeline1_cmd)) begin
    ram_rd_addr_buf = { 8'h00, pipeline0 };
end else if (add_a_ri(pipeline0_cmd)|addc_a_ri(pipeline0_cmd)|subb_a_ri(pipeline0_cmd)|inc_ri(pipeline0_cmd)|dec_ri(pipeline0_cmd)|anl_a_ri(pipeline0_cmd)|orl_a_ri(pipeline0_cmd)|xrl_a_ri(pipeline0_cmd)|mov_a_ri(pipeline0_cmd)|mov_di_ri(pipeline0_cmd)|mov_ri_a(pipeline0_cmd)|mov_ri_di(pipeline0_cmd)|mov_ri_da(pipeline0_cmd)|movx_a_ri(pipeline0_cmd)|movx_ri_a(pipeline0_cmd)|xch_a_ri(pipeline0_cmd)|xchd(pipeline0_cmd)|cjne_ri_da_rel(pipeline0_cmd)) begin
    ram_rd_addr_buf = { 11'h00, psw_rs1, psw_rs0, 2'b0, pipeline0_cmd[0] };
end else if (add_a_ri(pipeline1_cmd)|addc_a_ri(pipeline1_cmd)|subb_a_ri(pipeline1_cmd)|inc_ri(pipeline1_cmd)|dec_ri(pipeline1_cmd)|anl_a_ri(pipeline1_cmd)|orl_a_ri(pipeline1_cmd)|xrl_a_ri(pipeline1_cmd)|mov_a_ri(pipeline1_cmd)|mov_di_ri(pipeline1_cmd)|movx_a_ri(pipeline1_cmd)|xch_a_ri(pipeline1_cmd)|xchd(pipeline1_cmd)|cjne_ri_da_rel(pipeline1_cmd)) begin
    ram_rd_addr_buf = { 8'h00, ram_rd_data_0 };
end else if (movx_a_dp(pipeline0_cmd)) begin
    ram_rd_addr_buf = dp;
end else if (pop(pipeline0_cmd)|ret(pipeline0_cmd)|reti(pipeline0_cmd)) begin
    ram_rd_addr_buf = sp;
end else if (clr_bit(pipeline1_cmd)|setb_bit(pipeline1_cmd)|cpl_bit(pipeline1_cmd)|anl_c_bit(pipeline1_cmd)|anl_c_nbit(pipeline1_cmd)|orl_c_bit(pipeline1_cmd)|orl_c_nbit(pipeline1_cmd)|mov_c_bit(pipeline1_cmd)|mov_bit_c(pipeline1_cmd)|jb(pipeline1_cmd)|jnb(pipeline1_cmd)|jbc(pipeline1_cmd)) begin
    ram_rd_addr_buf = pipeline0[7] ? {8'h00,pipeline0[7:3],3'b0} : {8'h00,3'b001,pipeline0[7:3]};    
end else if (ret(pipeline1_cmd)|reti(pipeline1_cmd)) begin
    ram_rd_addr_buf = sp_sub1;	
end else begin
    ram_rd_addr_buf = 16'd0;
end

assign	use_psw	=	
	(//ARITHMETIC OPERATIONS
		add_a_rn(pipeline0_cmd)|add_a_ri(pipeline0_cmd)| //add
		addc_a_rn(pipeline0_cmd)|addc_a_ri(pipeline0_cmd)| //addc
		subb_a_rn(pipeline0_cmd)|subb_a_ri(pipeline0_cmd)| //subb
		inc_rn(pipeline0_cmd)|inc_ri(pipeline0_cmd)| //inc
		dec_rn(pipeline0_cmd)|dec_ri(pipeline0_cmd))| //dec
	(//LOGICAL OPERATIONS
		anl_a_rn(pipeline0_cmd)|anl_a_ri(pipeline0_cmd)|
		orl_a_rn(pipeline0_cmd)|orl_a_ri(pipeline0_cmd)|
		xrl_a_rn(pipeline0_cmd)|xrl_a_ri(pipeline0_cmd))|
	(//DATA TRANSFER
		mov_a_rn(pipeline0_cmd)|mov_a_ri(pipeline0_cmd)|mov_di_rn(pipeline0_cmd)|mov_di_ri(pipeline0_cmd)|mov_ri_a(pipeline0_cmd)|mov_ri_di(pipeline0_cmd)|mov_ri_da(pipeline0_cmd)|
		movx_a_ri(pipeline0_cmd)|movx_ri_a(pipeline0_cmd)|
		xch_a_rn(pipeline0_cmd)|xch_a_ri(pipeline0_cmd)|
		xchd(pipeline0_cmd))|
	(//PROGRAM BRANCHING
		cjne_rn_da_rel(pipeline0_cmd)|cjne_ri_da_rel(pipeline0_cmd)|
		djnz_rn_rel(pipeline0_cmd));
		
	
assign	use_dp = movc_a_dp(pipeline0_cmd)|movx_a_dp(pipeline0_cmd)|jmp(pipeline0_cmd);
assign	use_acc = movc_a_dp(pipeline0_cmd)|movc_a_pc(pipeline0_cmd)|jmp(pipeline0_cmd);
assign	use_sp = pop(pipeline0_cmd)|ret(pipeline0_cmd)|reti(pipeline0_cmd);
assign	wait_en = (use_psw&wr_psw)|(use_dp&wr_dp)|(use_acc&wr_acc)|(use_sp&wr_sp);



//ram output
always @* begin
if (same_flag) begin
    ram_rd_data_0 = same_byte;
end else if (same_byte[7]) begin
    ram_rd_data_0 = acc;
end else if (same_byte[6]) begin
    ram_rd_data_0 = psw;
end else if (same_byte[5]) begin
    ram_rd_data_0 = dp[15:8];
end else if (same_byte[4]) begin
    ram_rd_data_0 = dp[7:0];
end else if (same_byte[3]) begin
    ram_rd_data_0 = sp;
end else if (same_byte[2]) begin
    ram_rd_data_0 = b;
end else begin
    ram_rd_data_0 = ram_rd_data;
end
end

always @ (posedge clk) begin
ram_rd_data_1 <= ram_rd_data_0;
end
    
always @(posedge clk or negedge rst)
if (~rst) begin
    same_flag <= 1'b0;
end else if (work_en) begin
    if (data_same|xdata_same) begin
	    same_flag <= 1'b1;
	end else begin
	    same_flag <= 1'b0;
	end
end else;

always @(posedge clk or negedge rst)
if (~rst) begin
    same_byte <= 8'd0;
end else if (work_en) begin
   if (data_same|xdata_same) begin
	    same_byte <= ram_wr_data;
	end else if (data_rd_en & (ram_rd_addr[7:0]==8'he0)) begin //acc
	    same_byte <= 1'b1<<7;
	end else if (data_rd_en & (ram_rd_addr[7:0]==8'hd0)) begin //psw
	    same_byte <= 1'b1<<6;
	end else if (data_rd_en & (ram_rd_addr[7:0]==8'h83)) begin //dph
	    same_byte <= 1'b1<<5;	
	end else if (data_rd_en & (ram_rd_addr[7:0]==8'h82)) begin //dpl
	    same_byte <= 1'b1<<4;	
	end else if (data_rd_en & (ram_rd_addr[7:0]==8'h81)) begin //sp
	    same_byte <= 1'b1<<3;
	end else if (data_rd_en & (ram_rd_addr[7:0]==8'hf0)) begin //b
	    same_byte <= 1'b1<<2;		
	end else begin
	    same_byte <= 8'b0;
	end
end else;

// end of read ram ******************************************/






// write ram ************************************************/

assign	data_wr_en_buf	= 
(//ARITHMETIC OPERATIONS
	inc_rn(pipeline1_cmd)|inc_ri(pipeline2_cmd)|inc_di(pipeline2_cmd)| //inc
	dec_rn(pipeline1_cmd)|dec_ri(pipeline2_cmd)|inc_di(pipeline2_cmd))| //dec
(//LOGICAL OPERATIONS
	anl_di_a(pipeline2_cmd)|anl_di_da(pipeline2_cmd)|
	orl_di_a(pipeline2_cmd)|orl_di_da(pipeline2_cmd)|
	xrl_di_a(pipeline2_cmd)|xrl_di_da(pipeline2_cmd))|
(//DATA TRANSFER
	mov_rn_a(pipeline1_cmd)|mov_rn_di(pipeline2_cmd)|mov_rn_da(pipeline1_cmd)|mov_di_a(pipeline1_cmd)|mov_di_rn(pipeline1_cmd)|mov_di_di(pipeline2_cmd)|mov_di_ri(pipeline2_cmd)|mov_di_da(pipeline2_cmd)|mov_ri_a(pipeline1_cmd)|mov_ri_di(pipeline2_cmd)|mov_ri_da(pipeline1_cmd)| //mov
	push(pipeline2_cmd)|pop(pipeline1_cmd)| //push & pop
	xch_a_rn(pipeline1_cmd)|xch_a_di(pipeline2_cmd)|xch_a_ri(pipeline2_cmd)| //xch
	xchd(pipeline2_cmd))| //xchd
(//BOOLEAN VARIABLE MANIPULATION
	clr_bit(pipeline2_cmd)|
	setb_bit(pipeline2_cmd)|
	cpl_bit(pipeline2_cmd)|
	mov_bit_c(pipeline2_cmd)|
	(jbc(pipeline2_cmd)&ram_rd_data_0[pipeline1[2:0]]))|
(//PROGRAM BRANCHING
	djnz_rn_rel(pipeline1_cmd)|djnz_di_rel(pipeline2_cmd)|
	acall(pipeline1_cmd)|acall(pipeline2_cmd)|
	lcall(pipeline1_cmd)|lcall(pipeline2_cmd));

assign	xdata_wr_en_buf	= movx_ri_a(pipeline1_cmd)|movx_dp_a(pipeline1_cmd);

assign	data_wr_internal = ((ram_wr_addr[7:0]==8'he0)|(ram_wr_addr[7:0]==8'hd0)|(ram_wr_addr[7:0]==8'h83)|(ram_wr_addr[7:0]==8'h82)|(ram_wr_addr[7:0]==8'h81)|(ram_wr_addr[7:0]==8'hf0));// data_wr_en &

assign	data_wr_en	= work_en & data_wr_en_buf & (~data_wr_internal);
assign	xdata_wr_en	= work_en & xdata_wr_en_buf;

assign	ram_wr_addr = ram_wr_addr_buf;
always @* begin
if (inc_rn(pipeline1_cmd)|dec_rn(pipeline1_cmd)|mov_rn_a(pipeline1_cmd)|mov_rn_da(pipeline1_cmd)|xch_a_rn(pipeline1_cmd)|djnz_rn_rel(pipeline1_cmd)) begin
    ram_wr_addr_buf = {psw_rs1, psw_rs0, pipeline1[2:0]};
end else if (inc_di(pipeline2_cmd)|dec_di(pipeline2_cmd)|anl_di_a(pipeline2_cmd)|anl_di_da(pipeline2_cmd)|orl_di_a(pipeline2_cmd)|orl_di_da(pipeline2_cmd)|xrl_di_a(pipeline2_cmd)|xrl_di_da(pipeline2_cmd)|mov_di_ri(pipeline2_cmd)|mov_di_da(pipeline2_cmd)|xch_a_di(pipeline2_cmd)|djnz_di_rel(pipeline2_cmd)) begin
    ram_wr_addr_buf = pipeline1;
end else if (inc_ri(pipeline2_cmd)|dec_ri(pipeline2_cmd)|mov_ri_di(pipeline2_cmd)|xch_a_ri(pipeline2_cmd)|xchd(pipeline2_cmd)) begin
    ram_wr_addr_buf = ram_rd_data_1;
end else if (mov_rn_di(pipeline2_cmd)) begin
    ram_wr_addr_buf = {psw_rs1, psw_rs0, pipeline2[2:0]};
end else if (mov_di_a(pipeline1_cmd)|mov_di_rn(pipeline1_cmd)|mov_di_di(pipeline2_cmd)|pop(pipeline1_cmd)) begin
    ram_wr_addr_buf = pipeline0;
end else if (mov_ri_a(pipeline1_cmd)|mov_ri_da(pipeline1_cmd)|movx_ri_a(pipeline1_cmd)) begin
    ram_wr_addr_buf = ram_rd_data_0;
end else if (movx_dp_a(pipeline1_cmd)) begin
    ram_wr_addr_buf = dp;
end else if (push(pipeline2_cmd)) begin
    ram_wr_addr_buf = sp;
end else if (clr_bit(pipeline2_cmd)|setb_bit(pipeline2_cmd)|cpl_bit(pipeline2_cmd)|mov_bit_c(pipeline2_cmd)|jbc(pipeline2_cmd)) begin
    ram_wr_addr_buf = pipeline1[7] ? {pipeline1[7:3],3'b0} : {3'b001,pipeline1[7:3]};
end else if (acall(pipeline1_cmd)|acall(pipeline2_cmd)|lcall(pipeline1_cmd)|lcall(pipeline2_cmd)) begin
    ram_wr_addr_buf = sp_add1;	
end else begin
    ram_wr_addr_buf = 16'd0;
end
end

always @*
if (inc_rn(pipeline1_cmd)|inc_di(pipeline2_cmd)|inc_ri(pipeline2_cmd)|dec_rn(pipeline1_cmd)|dec_di(pipeline2_cmd)|dec_ri(pipeline2_cmd)|djnz_rn_rel(pipeline1_cmd)|djnz_di_rel(pipeline2_cmd)) begin
    ram_wr_data_buf = add_byte;
end else if (anl_di_a(pipeline2_cmd)|anl_di_da(pipeline2_cmd)) begin
    ram_wr_data_buf = acc_and;
end else if (orl_di_a(pipeline2_cmd)|orl_di_da(pipeline2_cmd)) begin
    ram_wr_data_buf = acc_or;
end else if (xrl_di_a(pipeline2_cmd)|xrl_di_da(pipeline2_cmd)) begin
    ram_wr_data_buf = acc_xor;
end else if (mov_rn_a(pipeline1_cmd)|mov_di_a(pipeline1_cmd)|mov_ri_a(pipeline1_cmd)|movx_ri_a(pipeline1_cmd)|movx_dp_a(pipeline1_cmd)|xch_a_rn(pipeline1_cmd)|xch_a_di(pipeline2_cmd)|xch_a_ri(pipeline2_cmd)) begin
    ram_wr_data_buf = acc;
end else if (mov_rn_di(pipeline2_cmd)|mov_di_rn(pipeline1_cmd)|mov_di_di(pipeline2_cmd)|mov_di_ri(pipeline2_cmd)|mov_ri_di(pipeline2_cmd)|push(pipeline2_cmd)|pop(pipeline1_cmd)) begin
    ram_wr_data_buf = ram_rd_data_0;
end else if (mov_rn_da(pipeline1_cmd)|mov_di_da(pipeline2_cmd)|mov_ri_da(pipeline1_cmd)) begin
    ram_wr_data_buf = pipeline0;
end else if (xchd(pipeline2_cmd)) begin
    ram_wr_data_buf = {ram_rd_data_0[7:4],acc[3:0]};
end else if (clr_bit(pipeline2_cmd)|setb_bit(pipeline2_cmd)|cpl_bit(pipeline2_cmd)|mov_bit_c(pipeline2_cmd)|jbc(pipeline2_cmd)) begin
    ram_wr_data_buf = ram_wr_data_bit_operate;
end else if (acall(pipeline1_cmd)) begin
    ram_wr_data_buf = pc[7:0];
end else if (acall(pipeline2_cmd)|lcall(pipeline2_cmd)) begin
    ram_wr_data_buf = pc[15:8];	
end else if (lcall(pipeline1_cmd)) begin
    ram_wr_data_buf = pc_add1[7:0];
end else begin
    ram_wr_data_buf = 8'd0;
end
assign ram_wr_data = ram_wr_data_buf;



// single bit operation
always @* begin
ram_wr_data_bit_operate = ram_rd_data_0;
if (clr_bit(pipeline2_cmd)|jbc(pipeline2_cmd))
    ram_wr_data_bit_operate[pipeline1[2:0]] = 1'b0;
else if (setb_bit(pipeline2_cmd))
    ram_wr_data_bit_operate[pipeline1[2:0]] = 1'b1;
else if (cpl_bit(pipeline2_cmd)	)
    ram_wr_data_bit_operate[pipeline1[2:0]] = ~ram_wr_data_bit_operate[pipeline1[2:0]];
else if (mov_bit_c(pipeline2_cmd))	
    ram_wr_data_bit_operate[pipeline1[2:0]] = psw_cy;
else;
end

// end of write ram *****************************************/






// ACC & ALU ************************************************/

// ACC has been defined in "important register"
always @(posedge clk or negedge rst) begin
	if (~rst) begin
		acc <= 8'h00;
	end else if (work_en) begin
    	if (data_wr_en_buf & (ram_wr_addr[7:0]==8'he0)) begin
		    acc <= ram_wr_data;
		end else if (add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|add_a_da(pipeline1_cmd)|addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|addc_a_da(pipeline1_cmd)|subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)|subb_a_da(pipeline1_cmd)|inc_a(pipeline1_cmd)|dec_a(pipeline1_cmd)) begin
		    acc <= add_byte;
		end else if (mul(pipeline1_cmd)) begin
		    acc <= acc_mult[7:0];
		end else if (div(pipeline1_cmd)) begin
		    acc <= acc_div_ans;
		end else if (da(pipeline1_cmd)) begin
		    acc <= {da_high,da_low};	
    	end else if (anl_a_rn(pipeline1_cmd)|anl_a_di(pipeline2_cmd)|anl_a_ri(pipeline2_cmd)|anl_a_da(pipeline1_cmd)) begin
    	    acc <= acc_and;	
		end else if (orl_a_rn(pipeline1_cmd)|orl_a_di(pipeline2_cmd)|orl_a_ri(pipeline2_cmd)|orl_a_da(pipeline1_cmd)) begin
		    acc <= acc_or;
		end else if (xrl_a_rn(pipeline1_cmd)|xrl_a_di(pipeline2_cmd)|xrl_a_ri(pipeline2_cmd)|xrl_a_da(pipeline1_cmd)) begin
		    acc <= acc_xor;
		end else if (clr_a(pipeline1_cmd)) begin
		    acc <= 8'b0;
		end else if (cpl_a(pipeline1_cmd)) begin
		    acc <= ~acc;
		end else if (rl(pipeline1_cmd)) begin
		    acc <= {acc[6:0],acc[7]};
		end else if (rlc(pipeline1_cmd)) begin
		    acc <= {acc[6:0],psw_cy};	
		end else if (rr(pipeline1_cmd)) begin
		    acc <= {acc[0],acc[7:1]};	
		end else if (rrc(pipeline1_cmd)) begin
		    acc <= {psw_cy,acc[7:1]};	
		end else if (swap(pipeline1_cmd)) begin
		    acc <= {acc[3:0],acc[7:4]};	
    	end else if (mov_a_rn(pipeline1_cmd)|mov_a_di(pipeline2_cmd)|mov_a_ri(pipeline2_cmd)|movx_a_ri(pipeline2_cmd)|movx_a_dp(pipeline1_cmd)|xch_a_rn(pipeline1_cmd)|xch_a_di(pipeline2_cmd)|xch_a_ri(pipeline2_cmd)) begin
    	    acc <= ram_rd_data_0;	
		end else if (mov_a_da(pipeline1_cmd)|movc_a_dp(pipeline1_cmd)|movc_a_pc(pipeline1_cmd)) begin
		    acc <= pipeline0;
		end else if (xchd(pipeline2_cmd)) begin
		    acc[3:0] <= ram_rd_data_0[3:0];
		end else;
	end
	else;
end

assign wr_acc = (data_wr_en & (ram_wr_addr[7:0]==8'he0))|add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|add_a_da(pipeline1_cmd)|addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|addc_a_da(pipeline1_cmd)|subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)|subb_a_da(pipeline1_cmd)|inc_a(pipeline1_cmd)|dec_a(pipeline1_cmd)|mul(pipeline1_cmd)|div(pipeline1_cmd)|da(pipeline1_cmd)|anl_a_rn(pipeline1_cmd)|anl_a_di(pipeline2_cmd)|anl_a_ri(pipeline2_cmd)|anl_a_da(pipeline1_cmd)|orl_a_rn(pipeline1_cmd)|orl_a_di(pipeline2_cmd)|orl_a_ri(pipeline2_cmd)|orl_a_da(pipeline1_cmd)|xrl_a_rn(pipeline1_cmd)|xrl_a_di(pipeline2_cmd)|xrl_a_ri(pipeline2_cmd)|xrl_a_da(pipeline1_cmd)|clr_a(pipeline1_cmd)|cpl_a(pipeline1_cmd)|rl(pipeline1_cmd)|rlc(pipeline1_cmd)|rr(pipeline1_cmd)|rrc(pipeline1_cmd)|swap(pipeline1_cmd)|mov_a_rn(pipeline1_cmd)|mov_a_di(pipeline2_cmd)|mov_a_ri(pipeline2_cmd)|mov_a_da(pipeline1_cmd)|movx_a_ri(pipeline2_cmd)|movx_a_dp(pipeline1_cmd)|xch_a_rn(pipeline1_cmd)|xch_a_di(pipeline2_cmd)|xch_a_ri(pipeline2_cmd)|xchd(pipeline2_cmd);



//2 input data and 2 flag of ALU
always @* begin
if (add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|add_a_da(pipeline1_cmd)|addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|addc_a_da(pipeline1_cmd)|subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)|subb_a_da(pipeline1_cmd)|inc_a(pipeline1_cmd)|dec_a(pipeline1_cmd)) begin
    add_a = acc;
end else if (inc_rn(pipeline1_cmd)|inc_di(pipeline2_cmd)|inc_ri(pipeline2_cmd)|dec_rn(pipeline1_cmd)|dec_di(pipeline2_cmd)|dec_ri(pipeline2_cmd)|djnz_rn_rel(pipeline1_cmd)|djnz_di_rel(pipeline2_cmd)) begin
    add_a = ram_rd_data_0;
end else begin
    add_a = 8'b0;
end
end

always @* begin
if (add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)) begin
    add_b = ram_rd_data_0;
end else if (add_a_da(pipeline1_cmd)|addc_a_da(pipeline1_cmd)|subb_a_da(pipeline1_cmd)) begin
    add_b = pipeline0;
end else if (inc_a(pipeline1_cmd)|dec_a(pipeline1_cmd)|inc_rn(pipeline1_cmd)|inc_di(pipeline2_cmd)|inc_ri(pipeline2_cmd)|dec_rn(pipeline1_cmd)|dec_di(pipeline2_cmd)|dec_ri(pipeline2_cmd)|djnz_rn_rel(pipeline1_cmd)|djnz_di_rel(pipeline2_cmd)) begin
    add_b = 8'b0;
end else begin
    add_b = 8'b0;
end 
end 

always @* begin
if (add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|add_a_da(pipeline1_cmd)) begin
    add_c = 1'b0;
end else if (addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|addc_a_da(pipeline1_cmd)|subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)|subb_a_da(pipeline1_cmd)) begin
    add_c = psw_cy;
end else if (inc_a(pipeline1_cmd)|inc_rn(pipeline1_cmd)|inc_di(pipeline2_cmd)|inc_ri(pipeline2_cmd)|dec_a(pipeline1_cmd)|dec_rn(pipeline1_cmd)|dec_di(pipeline2_cmd)|dec_ri(pipeline2_cmd)|djnz_rn_rel(pipeline1_cmd)|djnz_di_rel(pipeline2_cmd)) begin
    add_c = 1'b1;	
end else begin
    add_c = 1'b0;	
end 
end 

always @* begin
if (add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|add_a_da(pipeline1_cmd)|addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|addc_a_da(pipeline1_cmd)|inc_a(pipeline1_cmd)|inc_rn(pipeline1_cmd)|inc_di(pipeline2_cmd)|inc_ri(pipeline2_cmd)) begin
    sub_flag = 1'b0;
end else if (subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)|subb_a_da(pipeline1_cmd)|dec_a(pipeline1_cmd)|dec_rn(pipeline1_cmd)|dec_di(pipeline2_cmd)|dec_ri(pipeline2_cmd)|djnz_rn_rel(pipeline1_cmd)|djnz_di_rel(pipeline2_cmd)) begin
    sub_flag = 1'b1;
end else begin
    sub_flag = 1'b0;
end
end 



// add & sub & genarate value of psw
assign {psw_ac_buf,low}		    =	sub_flag ? (add_a[3:0]-add_b[3:0]-add_c) : (add_a[3:0]+add_b[3:0]+add_c);
assign high					    =	sub_flag ? (add_a[6:4]-add_b[6:4]-psw_ac_buf) : (add_a[6:4]+add_b[6:4]+psw_ac_buf);
assign {psw_cy_buf,bit_high}	=	sub_flag ? (add_a[7]-add_b[7]-high[3]) : (add_a[7]+add_b[7]+high[3]);
assign psw_ov_buf				=	psw_cy_buf ^ high[3];
assign add_byte			        =	{bit_high,high[2:0],low};

assign	acc_mult                    =	acc * b;
assign	{acc_div_rem, acc_div_ans}  =   divide(acc,b);

assign	acc_and	= (anl_di_da(pipeline2_cmd) ? pipeline0 : acc) & (anl_a_da(pipeline1_cmd) ? pipeline0 : ram_rd_data_0);
assign	acc_or	= (orl_di_da(pipeline2_cmd) ? pipeline0 : acc) | (orl_a_da(pipeline1_cmd) ? pipeline0 : ram_rd_data_0);
assign	acc_xor	= (xrl_di_da(pipeline2_cmd) ? pipeline0 : acc) ^ (xrl_a_da(pipeline1_cmd) ? pipeline0 : ram_rd_data_0);

assign  da_low  = (psw_ac|(acc[3:0]>4'h9)) ? (acc[3:0]+4'd6) : acc[3:0];
assign  da_high = ((psw_cy|(acc[7:4]>4'h9)|((acc[7:4]==4'h9) & (psw_ac | (acc[3:0]>4'h9)))) ? (acc[7:4]+4'h6) : acc[7:4]) + (acc[3:0]>4'h9);

// end of ACC & ALU *****************************************/






// PSW ******************************************************/

assign psw_p = ^acc;

always @(posedge clk or negedge rst) begin
	if (~rst) begin
		psw_ov <= 1'b0;
	end else if (work_en) begin
    	if (data_wr_en_buf & (ram_wr_addr[7:0]==8'hd0)) begin
		    psw_ov <= ram_wr_data[2];
		end else if (add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|add_a_da(pipeline1_cmd)|addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|addc_a_da(pipeline1_cmd)|subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)|subb_a_da(pipeline1_cmd)) begin
		    psw_ov <= psw_ov_buf;
		end else if (mul(pipeline1_cmd)) begin
		    psw_ov <= (acc_mult[15:8]!=8'b0);
		end else if (div(pipeline1_cmd)) begin
		    psw_ov <= (b==8'b0);
		end else;
	end else;
end

always @(posedge clk or negedge rst) begin
	if (~rst) begin
		psw_ac <= 1'b0;
	end else if (work_en) begin
    	if(data_wr_en_buf & (ram_wr_addr[7:0]==8'hd0)) begin
		    psw_ac <= ram_wr_data[6];
		end else if(add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|add_a_da(pipeline1_cmd)|addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|addc_a_da(pipeline1_cmd)|subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)|subb_a_da(pipeline1_cmd)) begin
		    psw_ac <= psw_ac_buf;
		end else;
	end else;
end

always @(posedge clk or negedge rst) begin
	if (~rst) begin
		psw_cy <= 1'b0;
	end else if (work_en) begin
    	if(data_wr_en_buf & (ram_wr_addr[7:0]==8'hd0)) begin
		    psw_cy <= ram_wr_data[7];
		end else if(add_a_rn(pipeline1_cmd)|add_a_di(pipeline2_cmd)|add_a_ri(pipeline2_cmd)|add_a_da(pipeline1_cmd)|addc_a_rn(pipeline1_cmd)|addc_a_di(pipeline2_cmd)|addc_a_ri(pipeline2_cmd)|addc_a_da(pipeline1_cmd)|subb_a_rn(pipeline1_cmd)|subb_a_di(pipeline2_cmd)|subb_a_ri(pipeline2_cmd)|subb_a_da(pipeline1_cmd)) begin
		    psw_cy <= psw_cy_buf;
		end else if(mul(pipeline1_cmd)|div(pipeline1_cmd)) begin
		    psw_cy <= 1'b0;
		end else if(da(pipeline1_cmd)) begin
		    psw_cy <=(psw_cy|(acc[7:4]>4'h9)|((acc[7:4]==4'h9)&(psw_ac|(acc[3:0]>4'h9)))) ? 1'b1 : psw_cy;
		end else if(rlc(pipeline1_cmd)) begin
		    psw_cy <= acc[7];	
		end else if(rrc(pipeline1_cmd)) begin
		    psw_cy <= acc[0];	
    	end else if(clr_c(pipeline1_cmd)) begin
    	    psw_cy <= 1'b0;	
		end else if(setb_c(pipeline1_cmd)) begin
    	    psw_cy <= 1'b1;	
		end else if(cpl_c(pipeline1_cmd)) begin
    	    psw_cy <= ~psw_cy;	
		end else if(anl_c_bit(pipeline2_cmd)) begin
    	    psw_cy <= psw_cy & ram_rd_data_0[pipeline1[2:0]];	
		end else if(anl_c_nbit(pipeline2_cmd)) begin
    	    psw_cy <= psw_cy & ~ram_rd_data_0[pipeline1[2:0]];
		end else if(orl_c_bit(pipeline2_cmd)) begin
    	    psw_cy <= psw_cy | ram_rd_data_0[pipeline1[2:0]];	
		end else if(orl_c_nbit(pipeline2_cmd)) begin
    	    psw_cy <= psw_cy | ~ram_rd_data_0[pipeline1[2:0]];	
		end else if(mov_c_bit(pipeline2_cmd)) begin
    	    psw_cy <=ram_rd_data_0[pipeline1[2:0]];
		end else if(cjne_a_di_rel(pipeline2_cmd)) begin
    	    psw_cy <= acc<ram_rd_data_0;
    	end else if(cjne_a_da_rel(pipeline2_cmd)) begin
    	    psw_cy <= acc<pipeline1;
		end else if(cjne_rn_da_rel(pipeline2_cmd)) begin
    	    psw_cy <= ram_rd_data_1<pipeline1;	
		end else if(cjne_ri_da_rel(pipeline2_cmd)) begin
		    psw_cy <= ram_rd_data_0<pipeline1;
		end else;
	end else;
end

always @(posedge clk or negedge rst) begin
	if (~rst) begin
		{psw_f0, psw_rs1, psw_rs0, psw_user} <= 4'h0;
	end else if (work_en) begin
		if (data_wr_en_buf & (ram_wr_addr[7:0]==8'hd0)) begin
			{psw_f0, psw_rs1, psw_rs0, psw_user} <= {ram_wr_data[5:3],ram_wr_data[1]};
		end else;
	end else;
end

assign wr_psw = data_wr_en & (ram_wr_addr[7:0]==8'hd0);

// end of PSW ***********************************************/






// DPTR, SP, B **********************************************/

// dptr
always @(posedge clk or negedge rst) begin
	if (~rst) begin
		dp <= 16'h0000;
	end else if (work_en) begin
    	if  (data_wr_en_buf & (ram_wr_addr[7:0]==8'h82)) begin
		    dp[7:0] <= ram_wr_data;
		end else if  (data_wr_en_buf & (ram_wr_addr[7:0]==8'h83)) begin
		    dp[15:8] <= ram_wr_data;
		end else if (inc_dp(pipeline1_cmd)) begin
		    dp <= dp + 1'b1;
		end else if (mov_dp_da(pipeline2_cmd)) begin
		    dp <= {pipeline1,pipeline0};
		end else;
	end else;
end
assign wr_dp = (data_wr_en & ((ram_wr_addr[7:0]==8'h82)|(ram_wr_addr[7:0]==8'h83)))|inc_dp(pipeline1_cmd);



// sp
always @(posedge clk or negedge rst) begin
	if (~rst) begin
		sp <= 8'h00;
	end else if (work_en) begin
    	if (data_wr_en_buf & (ram_wr_addr[7:0]==8'h81)) begin
		    sp <= ram_wr_data;
		end else if (push(pipeline1_cmd)|acall(pipeline1_cmd)|acall(pipeline2_cmd)|lcall(pipeline1_cmd)|lcall(pipeline2_cmd)) begin
		    sp <= sp_add1;
    	end else if (pop(pipeline1_cmd)|ret(pipeline1_cmd)|ret(pipeline2_cmd)|reti(pipeline1_cmd)|reti(pipeline2_cmd)) begin
    	    sp <= sp_sub1;	
		end else;
	end else;
end

assign sp_sub1 = sp - 1'b1;
assign sp_add1 = sp + 1'b1;
assign wr_sp = data_wr_en & (ram_wr_addr[7:0]==8'h81);



// b
always @(posedge clk or negedge rst) begin
	if (~rst) begin
		b <= 8'h00;
	end else if (work_en) begin
    	if (data_wr_en_buf & (ram_wr_addr[7:0]==8'hf0)) begin
		    b <= ram_wr_data;
		end else if (mul(pipeline1_cmd)) begin
		    b <= acc_mult[15:8];
		end else if (div(pipeline1_cmd)) begin
		    b <= acc_div_rem;
		end else;
	end else;
end

// end of DPTR, SP, B ***************************************/










endmodule 