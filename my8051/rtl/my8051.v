module my8051 (
	clk, rst, //basic signal
	p0//, p1, p2, p3 //port
);

// define pin
input 			clk, rst; //basic signal
inout [ 7: 0]	p0;//, p1, p2, p3; //port


// define wire***************************/
// rom
wire 	   [15: 0]	 rom_addr;
wire		[ 7: 0]	 rom_data;

// ram
//read
wire 	   [15: 0]	 ram_rd_addr;
wire		[ 7: 0]	 ram_rd_data;
wire               ram_rd_vld;
wire		[ 7: 0]	 data_rd_data;
wire               data_rd_vld;
wire		[ 7: 0]	 xdata_rd_data;
wire               xdata_rd_vld;

wire 				    data_rd_en;
wire 				    xdata_rd_en;

// write
wire 	   [15: 0]	 ram_wr_addr;
wire		[ 7: 0]	 ram_wr_data;

wire 				    data_wr_en;
wire 				    xdata_wr_en;

// end of define wire********************/

core core(
	.clk(clk),
	.rst(rst),
	.rom_addr(rom_addr),
	.rom_data(rom_data),
   .ram_rd_addr(ram_rd_addr),
	.ram_rd_data(ram_rd_data),
	.ram_rd_vld(ram_rd_vld),
	.data_rd_en(data_rd_en),
   .xdata_rd_en(xdata_rd_en),
   .ram_wr_addr(ram_wr_addr),
	.ram_wr_data(ram_wr_data),
	.data_wr_en(data_wr_en),
	.xdata_wr_en(xdata_wr_en)
);

rom rom(
	.clock(clk),
	.address(rom_addr),
	.q(rom_data)
);

ram ram(
	.clk(clk),
   .rd_addr(ram_rd_addr),
	.rd_data(ram_rd_data),
	.rd_vld(ram_rd_vld),
	.data_rd_en(data_rd_en),
   .xdata_rd_en(xdata_rd_en),
   .wr_addr(ram_wr_addr),
	.wr_data(ram_wr_data),
	.data_wr_en(data_wr_en),
	.xdata_wr_en(xdata_wr_en),
	.p0(p0), 
	.p1(), 
	.p2(), 
	.p3()
);


endmodule 