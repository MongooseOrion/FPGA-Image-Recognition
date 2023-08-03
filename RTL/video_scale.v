module video_scale (
	input			rst,
	input			pclk_in,
	input			vsync_in,
	input			href_in,
	input  [15:0]	i_rgb565_in,

	output			pclk_out,
	output			vsync_out,
	output			href_out,
	output [15:0]   i_rgb565_out
);

parameter IN_X = 1280;
parameter IN_Y = 720;
parameter OUT_X = 640;
parameter OUT_Y = 360;

reg 		pclk_out_reg = 1'b0;
wire		pclk_flag;
reg			vsync_out_reg = 1'b0;
wire 		vsync_flag;
reg			href_out_reg = 1'b0;
wire		href_flag;
reg	[15:0]	i_rgb565_out_reg;

reg [1:0]	flag_1 = 0;
reg [15:0]	flag_2 = 0;
reg [15:0]	flag_3 = 0;
reg [15:0]  flag_4 = 0;

always @ (posedge pclk_in or negedge rst) begin
	if(!rst) begin
		pclk_out_reg <= 0;
	end
	else begin
		flag_1 = flag_1 + 1;
		if(flag == 2) begin
			pclk_out_reg <= ~pclk_out_reg;
			flag <= 0;
		end
		else begin
			pclk_out_reg <= pclk_out_reg;
		end
	end
end

assign pclk_out = pclk_out_reg;
assign pclk_flag = pclk_out_reg;

always @ (posedge pclk_flag or negedge rst) begin
	if(!rst) begin
		href_out_reg <= 0;
	end
	else begin
		
