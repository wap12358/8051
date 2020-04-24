`timescale 1 ns/1 ns

`define PERIOD 10
`define HALF_PERIOD (`PERIOD/2)
`define CODE_FILE "./code.bin"


module tb_core;

reg     clk = 1'b1;
always #`HALF_PERIOD clk = ~clk;

reg     rst = 1'b0;
initial #(`PERIOD*1.5) rst = 1'b1;


wire [15:0]     rom_addr;
reg  [7:0]      rom_byte;

wire            data_rd_en;
wire            xdata_rd_en;
wire [15:0]     ram_rd_addr;
wire  [7:0]     ram_rd_data;
reg             ram_rd_vld;

wire            data_wr_en;
wire            xdata_wr_en;
wire [15:0]     ram_wr_addr;
wire [7:0]      ram_wr_data;


core core (
    .clk                  (    clk              ),
	.rst                  (    rst              ),
	
	.rom_addr             (    rom_addr         ),
	.rom_data             (    rom_byte         ),
	
	.data_rd_en           (    data_rd_en       ),
	.xdata_rd_en          (    xdata_rd_en      ),
	.ram_rd_addr          (    ram_rd_addr      ),
	.ram_rd_data          (    ram_rd_data      ),
	.ram_rd_vld           (    ram_rd_vld       ),
	
	.data_wr_en           (    data_wr_en       ),
	.xdata_wr_en          (    xdata_wr_en      ),
	.ram_wr_addr          (    ram_wr_addr      ),
	.ram_wr_data          (    ram_wr_data      )

);


reg [7:0] rom[(1'b1<<16)-1:0];

integer fd,fx;
initial begin
  fd = $fopen(`CODE_FILE,"rb");
  fx = $fread(rom,fd);
  $fclose(fd);
end
	
always @ ( posedge clk ) rom_byte <=  rom[rom_addr];



reg [7:0] data [255:0];
reg [7:0] data_rd_data;
always @ ( posedge clk )
if ( data_rd_en )
    data_rd_data <=  data[ram_rd_addr[7:0]];
else;

always @ ( posedge clk )
if ( data_wr_en )
    data[ram_wr_addr[7:0]] <=  ram_wr_data;
else;

reg [7:0] xdata [(1'b1<<16)-1:0];
reg [7:0] xdata_rd_data;
always @ ( posedge clk )
if ( xdata_rd_en )
    xdata_rd_data <=  xdata[ram_rd_addr[6:0]];
else;

always @ ( posedge clk )
if ( xdata_wr_en )
    xdata[ram_wr_addr[6:0]] <=  ram_wr_data;
else;

reg rd_flag;
always @ ( posedge clk )
if ( data_rd_en )
    rd_flag <= 1'b0;
else if ( xdata_rd_en )
    rd_flag <= 1'b1;	
else;

assign ram_rd_data = rd_flag ? xdata_rd_data : data_rd_data ;

always @(posedge clk) begin
    if ( data_rd_en | xdata_rd_en ) begin
        ram_rd_vld <= 1'b1;
    end else begin
        ram_rd_vld <= 1'b0;
    end
end

integer i;
initial begin
for(i=0;i<256;i=i+1)begin
    data[i]=8'h0;
end
for(i=0;i<(1'b1<<16);i=i+1)begin
    xdata[i]=8'h0;
end

end

endmodule
