module sfr(
	clk,
	data,
	wren,
	rden,
	address,
	q,
	p0, 
	p1, 
	p2, 
	p3
);

// module port
input					clk;
input		[ 7: 0]		data;
input					wren;
input					rden;
input		[ 6: 0]		address;
output reg	[ 7: 0]		q;
inout		[ 7: 0]		p0; 
inout		[ 7: 0]		p1;
inout		[ 7: 0]		p2;
inout		[ 7: 0]		p3;


// external port p0-p3
reg					p0_out_en, p1_out_en, p2_out_en, p3_out_en;
reg		[ 7: 0]		p0_reg, p1_reg, p2_reg, p3_reg;

assign  p0 = p0_out_en ? p0_reg : 8'hzz;
assign  p1 = p1_out_en ? p1_reg : 8'hzz;
assign  p2 = p2_out_en ? p2_reg : 8'hzz;
assign  p3 = p3_out_en ? p3_reg : 8'hzz;

always @* begin
	if (rden) begin
		case (address)
		7'h00:	begin p0_out_en = 1'b0; end		
		7'h10:	begin p1_out_en = 1'b0; end
		7'h20:	begin p2_out_en = 1'b0; end
		7'h30:	begin p3_out_en = 1'b0; end		
		default: begin  end
		endcase
	end else if (wren) begin
		case (address)
		7'h00:	begin p0_out_en = 1'b1; end		
		7'h10:	begin p1_out_en = 1'b1; end
		7'h20:	begin p2_out_en = 1'b1; end
		7'h30:	begin p3_out_en = 1'b1; end		
		default: begin  end
		endcase
	end else;
end

always @(posedge clk) begin
if (wren) begin
	case (address)
	7'h00:	begin p0_reg <= data; end
	7'h10:	begin p1_reg <= data; end
	7'h20:	begin p2_reg <= data; end
	7'h30:	begin p3_reg <= data; end
	default: begin end
	endcase
end
end

always @* begin
if (rden) begin
	case (address)
	//external port
	7'h00:	begin q = p0; end
	7'h10:	begin q = p1; end
	7'h20:	begin q = p2; end
	7'h30:	begin q = p3; end
	default: begin q = 8'h00; end
	endcase
end
end



endmodule 

/*
缺少的寄存器:
	中断:
		B8:IP
		A8:IE
	串口：
		98:SCON
		99:SBUF
	计数器:
		88:TOON
		89:TMOD
		8A:TL0
		8B:TL1
		8C:TH0
		8D:TH1
	功耗控制:
		87:PCON

*/