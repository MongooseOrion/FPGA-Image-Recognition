///////////////////////////////////////////////////////////////////////////////////////
// 该模块实现了 AHB-Lite 到 AXI4-Lite 桥。代码中主要包含了
// AHB-Lite 和 AXI4-Lite 之间的信号映射以及控制状态的逻辑，以实现两个总线之间
// 的数据传输和通信。将 AHB-Lite 主机的地址和控制信号转换为AXI4-Lite
// 主机的地址和控制信号，同时将 AXI4-Lite 从机的数据转换为 AHB-Lite 从机的数据。
///////////////////////////////////////////////////////////////////////////////////////

module ahb_axi_bridge (
    // AHB-Lite
    input           clk,
    input           reset,
    input   [31:0]  haddr,
    input   [2:0]   hburst,
    input   [2:0]   hsize,
    input   [3:0]   hprot,
    input           hwdata_valid,
    input   [15:0]  hwdata,
    input           hsel,
    input   [1:0]   htrans,
    input           hwrite,
    output  [127:0] hrdata,
    input           intr,
    output          hready,
    output  [1:0]   hresp,
    
    // AXI4 Lite
    // write address signal
    input           awready,
    output          awuser,
    output  [31:0]  awaddr,
    output  [3:0]   awid,
    output  [3:0]   awlen,
    output          awvalid,
    output          awburst,
    // read address signal
    input           arready,
    output          arvalid,
    output  [31:0]  araddr,
    output  [3:0]   arid,
    output          aruser,
    output  [3:0]   arlen,
    output          arburst,
    // write signal
    input           wready,
    input   [3:0]   wid,
    input           wlast,
    output  [15:0]  wdata,
    output  [15:0]  wstrb,
    output          wvalid,
    // read address
    input   [127:0] rdata,
    input   [1:0]   rresp,
    input           rvalid,
    input           rlast,
    input   [3:0]   rid,
    input   [1:0]   rready

);

reg         axi_awready;
reg [31:0]  axi_awaddr;
reg [3:0]   axi_awid;
reg [3:0]   axi_awlen;
reg         axi_awvalid;
reg [2:0]   axi_awburst;

reg         axi_arready;
reg         axi_arvalid;
reg [31:0]  axi_araddr;
reg [3:0]   axi_arid;
reg [3:0]   axi_arlen;
reg [2:0]   axi_arburst;

reg         axi_wready;
reg [3:0]   axi_wid;
reg         axi_wlast;
reg [15:0]  axi_wdata;
reg [15:0]  axi_wstrb;
reg         axi_wvalid;

reg [127:0] axi_rdata;
reg [1:0]   axi_rresp;
reg         axi_rvalid;
reg [1:0]   axi_rready;
reg [3:0]   axi_rid;

reg         axi_bready;
reg         axi_bvalid;
reg         axi_bid;
reg         axi_bresp;
reg         axi_hready;
reg         axi_hresp;
reg [127:0] axi_hrdata;

reg         axi_arvalid_dg;
reg         axi_awvalid_dg;
reg         axi_wvalid_dg;
reg         axi_arburst_dg;
reg         axi_arid_dg;
reg         axi_rvalid_dg;
reg         axi_bvalid_dg;

wire        axi_arvalid_dl;
wire        axi_awvalid_dl;
wire        axi_wvalid_dl;
wire        axi_arburst_dl;
wire        axi_arid_dl;
wire        axi_rvalid_dl;
wire        axi_bvalid_dl;

//assign  axi_arvalid_dl = axi_arvalid_dg;
//assign  axi_awvalid_dl = axi_awvalid_dg;
//assign  axi_wvalid_dl = axi_wvalid_dg;
//assign  axi_arburst_dl = axi_arburst_dg;
//assign  axi_arid_dl = axi_arid_dg;
assign  axi_rvalid_dl = axi_rvalid_dg;
assign  axi_bvalid_dl = axi_bvalid_dg;


// generate read address signals
assign axi_arburst_dl = (hburst == 3'b000) ? 3'b000 :
                        (hburst == 3'b001) ? 3'b001 :
                        (hburst == 3'b010) ? 3'b010 :
                        (hburst == 3'b011) ? 3'b011 : 3'b000;
assign axi_arid_dl = (hsel == 2'b00) ? 2'b00 : 2'b01;

assign  hready = axi_hready;
assign  hresp = axi_hresp;
assign  hrdata = axi_hrdata;
assign  arburst = axi_arburst;
assign  arid = axi_arid;
assign  arvalid = axi_arvalid;
assign  araddr = axi_araddr;
assign  arlen = axi_arlen;
assign  awaddr = axi_awaddr;
assign  awburst = axi_awburst;
assign  awvalid = axi_awvalid;
assign  awid = axi_awid;
assign  awlen = axi_awlen;
assign  wdata = axi_wdata;
//assign  wready = axi_wready;
assign  wvalid = axi_wvalid;
assign  wstrb = axi_wstrb;
//assign  rready = axi_rready;
//assign  rresp = axi_rresp;
//assign  rvalid = axi_rvalid;



always @(posedge clk or negedge reset) begin
    if (!reset) begin
        axi_arvalid <= 1'b0;
        axi_awvalid <= 1'b0;
        axi_wvalid <= 1'b0;
        axi_arburst <= 3'b000;
        axi_awburst <= 3'b000;
        axi_arid <= 2'b00;
        axi_awid <= 2'b00;
    end 
    else begin
        case ({htrans, hwrite})
        2'b00_1 : begin // HREAD
                    axi_araddr <= haddr;
                    axi_arlen <= hsize;
                    axi_arburst <= axi_arburst_dl;
                    axi_arid <= axi_arid_dl;
                    axi_arvalid <= 1'b1;
                    axi_awvalid <= 1'b0;
                    axi_wvalid <= 1'b0;
        end
        2'b01_1 : begin // HWRITE
                    axi_awaddr <= haddr;
                    axi_awlen <= hsize;
                    axi_awburst <= axi_awburst;
                    axi_awid <= axi_awid;
                    axi_arvalid <= 1'b0;
                    axi_awvalid <= 1'b1;
                    axi_wvalid <= 1'b1;
        end
        default : begin
                    axi_arvalid <= 1'b0;
                    axi_awvalid <= 1'b0;
                    axi_wvalid <= 1'b0;
        end
        endcase
    end
end

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        axi_wdata <= 16'h0;
        axi_wstrb <= 16'h0;
    end 
    else begin
        if (axi_wvalid) begin
            axi_wdata <= hwdata;
            axi_wstrb <=    (hsize == 2'b00) ? 16'h0001 :
                            (hsize == 2'b01) ? {hwdata_valid, 14'h0000, hwdata_valid} :
                            (hsize == 2'b10) ? {hwdata_valid, hwdata_valid, 12'h0000} :
                            (hsize == 2'b11) ? 16'hffff : 16'h0001;
        end
    end
end

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        axi_hready <= 1'b0;
    end 
    else begin
        case ({axi_arvalid, axi_awvalid, axi_wvalid})
        3'b100 : begin // AR only
                    axi_hready <= arready;
        end
        3'b010 : begin // AW only
                    axi_hready <= awready;
        end
        3'b001 : begin // W only
                axi_hready <= 1'b1;
        end
        3'b011 : begin // AW and W
                axi_hready <= (awready & 1'b1);
        end
        3'b101 : begin
                axi_hready <= (arready & 1'b1);
        end
        3'b111 : begin // AR, AW, and W
                axi_hready <= (arready & awready & 1'b1);
        end
        default : begin
                axi_hready <= 1'b0;
        end
        endcase
    end
end
/*
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        axi_arvalid_dg <= 1'b0;
        axi_awvalid_dg <= 1'b0;
        axi_wvalid_dg <= 1'b0;
    end 
    else begin
        axi_arvalid_dg <= axi_arvalid;
        axi_awvalid_dg <= axi_awvalid;
        axi_wvalid_dg <= axi_wvalid;
    end
end
*/
/*
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        axi_arready <= 1'b0;
        axi_awready <= 1'b0;
        //axi_wready <= 1'b0;
    end 
    else begin
        axi_arready <= (axi_arvalid_dl & hready & (axi_rready | !axi_rvalid));
        axi_awready <= (axi_awvalid_dl & hready & (axi_bready | !axi_bvalid));
        //axi_wready <= (axi_wvalid_dl & hready);
    end
end
*/
/*
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        //axi_rvalid <= 1'b0;
        axi_bvalid <= 1'b0;
        //axi_rresp <= 2'b00;
        axi_bid <= 2'b00;
    end 
    else begin
        case ({axi_arvalid_dl, axi_awvalid_dl, axi_rvalid_dl, axi_bvalid_dl})
        4'b0001 : begin // AR only
                    //axi_rvalid <= arready & axi_arvalid_dl & axi_rready;
                    axi_bvalid <= axi_bvalid_dl;
                    //axi_rresp <= (axi_rvalid) ? 2'b00 : axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b0010 : begin // AW only
                    //axi_rvalid <= axi_rvalid_dl;
                    axi_bvalid <= awready & axi_awvalid_dl & axi_bready;
                    //axi_rresp <= axi_rresp;
                    axi_bid <= (axi_bvalid) ? axi_awid : axi_bid;
        end
        4'b0100 : begin // R only
                    //axi_rvalid <= axi_rvalid_dl;
                    axi_bvalid <= axi_bvalid_dl;
                    //axi_rresp <= axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b1000 : begin // B only
                    //axi_rvalid <= axi_rvalid_dl;
                    axi_bvalid <= axi_bvalid_dl;
                    //axi_rresp <= axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b0011 : begin // AW and R
                    //axi_rvalid <= arready & axi_arvalid_dl & axi_rready;
                    axi_bvalid <= axi_bvalid_dl;
                    //axi_rresp <= (axi_rvalid) ? 2'b00 : axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b0101 : begin // AR and R
                    //axi_rvalid <= arready & axi_arvalid_dl & axi_rready;
                    axi_bvalid <= axi_bvalid_dl;
                    //axi_rresp <= (axi_rvalid) ? 2'b00 : axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b0110 : begin // AR and AW
                    //axi_rvalid <= axi_rvalid_dl;
                    axi_bvalid <= awready & axi_awvalid_dl & axi_bready;
                    //axi_rresp <= axi_rresp;
                    axi_bid <= (axi_bvalid) ? axi_awid : axi_bid;
        end
        4'b0111 : begin // AR, AW, and R
                    //axi_rvalid <= arready & awready & axi_arvalid_dl & axi_rready;
                    axi_bvalid <= axi_bvalid_dl;
                    //axi_rresp <= (axi_rvalid) ? 2'b00 : axi_rresp;
                    axi_bid <= axi_bid;
        end
        default : begin
                    //axi_rvalid <= axi_rvalid;
                    axi_bvalid <= 1'b0;
                    //axi_rresp <= axi_rresp;
                    axi_bid <= 2'b00;
        end
        endcase
    end
end
*/
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        axi_hrdata <= 128'h0;
        axi_bresp <= 2'b00;
    end 
    else begin
        if (rvalid & rready) begin
            axi_hrdata <= rdata;
            axi_bresp <= axi_bresp;
        end 
        else if (axi_bvalid & axi_bready) begin
            axi_hrdata <= rdata;
            axi_bresp <= axi_bresp;
        end 
        else begin
            axi_hrdata <= rdata;
            axi_bresp <= axi_bresp;
        end
    end
end

always @(posedge clk or negedge reset) begin
    if(!reset) begin
        axi_hresp <= 2'b00;
    end
    else begin
        case(rvalid)
        1'b0: begin
            axi_hresp <= axi_hresp;
        end
        1'b1: begin
            axi_hresp <= (axi_rresp == 2'b00) ? 2'b00 : 2'b10;
        end
        default: begin
            axi_hresp <= 2'b00;
        end
        endcase
    end
end


endmodule