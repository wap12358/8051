module ram (
	clk,
   	rd_addr, rd_data, rd_vld,
   	wr_addr, wr_data,
	data_rd_en, xdata_rd_en,
	data_wr_en, xdata_wr_en,
	p0, p1, p2, p3
);

// parameter
parameter	XDATA_ADDR_WIDTH	=	12;


// basic signal
input					clk;

// read
input	   	[15: 0]		rd_addr;
input 				    data_rd_en;
input 				    xdata_rd_en;

output reg	[ 7: 0]		rd_data;
output           		rd_vld;

wire		[ 7: 0]	 	data_rd_data;
reg               		data_rd_vld;
wire		[ 7: 0]	 	xdata_rd_data;
reg               		xdata_rd_vld;

wire		[ 7: 0]		main_rd_data;
wire		[ 7: 0]		sfr_rd_data;


// write
input 	   	[15: 0]	 	wr_addr;
input		[ 7: 0]	 	wr_data;

input 				    data_wr_en;
input 				    xdata_wr_en;

// external port
inout		[ 7: 0]		p0;
inout		[ 7: 0]		p1;
inout		[ 7: 0]		p2;
inout		[ 7: 0]		p3;

// address
reg			[15: 0]		address;

// data
wire					main_wr_en;
wire					main_rd_en;
wire					sfr_wr_en;
wire					sfr_rd_en;

assign	main_rd_en	=	data_rd_en & (~rd_addr[7]);
assign	main_wr_en	=	data_wr_en & (~wr_addr[7]);
assign	sfr_rd_en	=	data_rd_en & rd_addr[7];
assign	sfr_wr_en	=	data_wr_en & wr_addr[7];

// address
always @* begin
	if (data_wr_en | xdata_wr_en) begin
		address = wr_addr;
	end else if (data_rd_en | xdata_rd_en) begin
		address = rd_addr;
	end
end

// data_rd_vld
always @(posedge clk) begin
	if (data_rd_en & (~data_wr_en)) begin
		data_rd_vld <= 1'b1;
	end else begin
		data_rd_vld <= 1'b0;
	end
end

// xdata_rd_vld
always @(posedge clk) begin
	if (xdata_rd_en & (~xdata_wr_en)) begin
		xdata_rd_vld <= 1'b1;
	end else begin
		xdata_rd_vld <= 1'b0;
	end
end


data data(
	.clock(clk),
	.data(wr_data),
	.wren(main_wr_en),
	.rden(main_rd_en),
	.address(address[6:0]),
	.q(main_rd_data)
);

sfr sfr(
	.clk(clk),
	.data(wr_data),
	.wren(sfr_wr_en),
	.rden(sfr_rd_en),
	.address(address[6:0]),
	.q(sfr_rd_data),
	.p0(p0),
	.p1(p1),
	.p2(p2),
	.p3(p3)
);

xdata xdata(
	.clock(clk),
	.data(wr_data),
	.wren(xdata_wr_en),
	.rden(xdata_rd_en),
	.address(address[XDATA_ADDR_WIDTH-1:0]),
	.q(xdata_rd_data)
);


assign rd_vld = data_rd_vld | xdata_rd_vld;

always @* begin
	if (main_rd_en) begin
		rd_data = main_rd_data;
	end else if (sfr_rd_en) begin
		rd_data = sfr_rd_data;
	end else if (xdata_rd_en) begin
		rd_data = xdata_rd_data;
	end
end


endmodule 