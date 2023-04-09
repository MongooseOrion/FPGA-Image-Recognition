///////////////////////////////////////////////////////////////////////////////////////
// ��ģ��ʵ���� AHB-Lite �� AXI4-Lite �š���������Ҫ������
// AHB-Lite �� AXI4-Lite ֮����ź�ӳ���Լ�����״̬���߼�����ʵ����������֮��
// �����ݴ����ͨ�š��� AHB-Lite �����ĵ�ַ�Ϳ����ź�ת��ΪAXI4-Lite
// �����ĵ�ַ�Ϳ����źţ�ͬʱ�� AXI4-Lite �ӻ�������ת��Ϊ AHB-Lite �ӻ������ݡ�
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
    input   [31:0]  hwdata,
    input   [1:0]   hsel,
    input   [1:0]   htrans,
    input           hwrite,
    input           hrdata,
    input           intr,
    output          hready,
    
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
    output          arburst;
    // write signal
    input           wready,
    input   [3:0]   wid,
    input           wlast,
    output  [127:0] wdata,
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
reg [127:0] axi_wdata;
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

reg         axi_arvalid_d1;
reg         axi_awvalid_d1;
reg         axi_wvalid_d1;


// HSIZE mapping to AXI4's data width
wire [1:0] axi_data_size =  (hsize == 2'b00) ? 2'b00 : 
                            (hsize == 2'b01) ? 2'b01 : 
                            (hsize == 2'b10) ? 2'b10 : 
                            (hsize == 2'b11) ? 2'b11 : 2'b00;

// HPROT mapping to AXI4's protection level
wire [2:0] axi_prot_level = (hprot == 3'b000) ? 3'b000 :
                            (hprot == 3'b001) ? 3'b001 :
                            (hprot == 3'b010) ? 3'b010 :
                            (hprot == 3'b011) ? 3'b011 :
                            (hprot == 3'b100) ? 3'b101 :
                            (hprot == 3'b101) ? 3'b110 : 3'b111;

// generate read address signals
assign araddr = haddr;
assign arlen = hsize;
assign axi_arburst_d1 = (hburst == 3'b000) ? 3'b000 :
                        (hburst == 3'b001) ? 3'b001 :
                        (hburst == 3'b010) ? 3'b010 :
                        (hburst == 3'b011) ? 3'b011 : 3'b000;
assign axi_arid_d1 = (hsel == 2'b00) ? 2'b00 : 2'b01;


always @(posedge clk) begin
    if (reset) begin
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
                    axi_arburst <= axi_arburst_d1;
                    axi_arid <= axi_arid_d1;
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

assign arburst = axi_arburst;
assign arid = axi_arid;

always @(posedge clk) begin
    if (reset) begin
        axi_wdata <= 32'h0;
        axi_wstrb <= 4'h0;
    end 
    else begin
        if (axi_wvalid) begin
            axi_wdata <= hwdata;
            axi_wstrb <=    (hsize == 2'b00) ? 4'h1 :
                            (hsize == 2'b01) ? {hwdata_valid, 1'b0, hwdata_valid} :
                            (hsize == 2'b10) ? {hwdata_valid, hwdata_valid} :
                            (hsize == 2'b11) ? 4'hf : 4'h1;
        end
    end
end

always @(posedge clk) begin
    if (reset) begin
        axi_hready <= 1'b0;
    end 
    else begin
        case ({axi_arvalid, axi_awvalid, axi_wvalid})
        3'b100 : begin // AR only
                    axi_hready <= arready[hsel];
        end
        3'b010 : begin // AW only
                    axi_hready <= awready[hsel];
        end
        3'b001 : begin // W only
                axi_hready <= 1'b1;
        end
        3'b011 : begin // AW and W
                axi_hready <= (awready[hsel] & 1'b1);
        end
        3'b101 : begin
                axi_hready <= (arready[hsel] & 1'b1);
        end
        3'b111 : begin // AR, AW, and W
                axi_hready <= (arready[hsel] & awready[hsel] & 1'b1);
        end
        default : begin
                axi_hready <= 1'b0;
        end
        endcase
    end
end

assign hready = axi_hready;
assign hrdata = axi_rdata;


always @(posedge clk) begin
    if (reset) begin
        axi_arvalid_d1 <= 1'b0;
        axi_awvalid_d1 <= 1'b0;
        axi_wvalid_d1 <= 1'b0;
    end 
    else begin
        axi_arvalid_d1 <= axi_arvalid;
        axi_awvalid_d1 <= axi_awvalid;
        axi_wvalid_d1 <= axi_wvalid;
    end
end

always @(posedge clk) begin
    if (reset) begin
        axi_arready <= 1'b0;
        axi_awready <= 1'b0;
        axi_wready <= 1'b0;
    end 
    else begin
        axi_arready <= (axi_arvalid_d1 & hready & (axi_rready | !axi_rvalid));
        axi_awready <= (axi_awvalid_d1 & hready & (axi_bready | !axi_bvalid));
        axi_wready <= (axi_wvalid_d1 & hready);
    end
end

always @(posedge clk) begin
    if (reset) begin
        axi_rvalid <= 1'b0;
        axi_bvalid <= 1'b0;
        axi_rresp <= 2'b00;
        axi_bid <= 2'b00;
    end 
    else begin
        case ({axi_arvalid_d1, axi_awvalid_d1, axi_rvalid_d1, axi_bvalid_d1})
        4'b0001 : begin // AR only
                    axi_rvalid <= arready[hsel] & axi_arvalid_d1 & axi_rready;
                    axi_bvalid <= axi_bvalid_d1;
                    axi_rresp <= (axi_rvalid) ? 2'b00 : axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b0010 : begin // AW only
                    axi_rvalid <= axi_rvalid_d1;
                    axi_bvalid <= awready[hsel] & axi_awvalid_d1 & axi_bready;
                    axi_rresp <= axi_rresp;
                    axi_bid <= (axi_bvalid) ? axi_awid : axi_bid;
        end
        4'b0100 : begin // R only
                    axi_rvalid <= axi_rvalid_d1;
                    axi_bvalid <= axi_bvalid_d1;
                    axi_rresp <= axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b1000 : begin // B only
                    axi_rvalid <= axi_rvalid_d1;
                    axi_bvalid <= axi_bvalid_d1;
                    axi_rresp <= axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b0011 : begin // AW and R
                    axi_rvalid <= arready[hsel]& axi_arvalid_d1 & axi_rready;
                    axi_bvalid <= axi_bvalid_d1;
                    axi_rresp <= (axi_rvalid) ? 2'b00 : axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b0101 : begin // AR and R
                    axi_rvalid <= arready[hsel] & axi_arvalid_d1 & axi_rready;
                    axi_bvalid <= axi_bvalid_d1;
                    axi_rresp <= (axi_rvalid) ? 2'b00 : axi_rresp;
                    axi_bid <= axi_bid;
        end
        4'b0110 : begin // AR and AW
                    axi_rvalid <= axi_rvalid_d1;
                    axi_bvalid <= awready[hsel] & axi_awvalid_d1 & axi_bready;
                    axi_rresp <= axi_rresp;
                    axi_bid <= (axi_bvalid) ? axi_awid : axi_bid;
        end
        4'b0111 : begin // AR, AW, and R
                    axi_rvalid <= arready[hsel] & awready[hsel] & axi_arvalid_d1 & axi_rready;
                    axi_bvalid <= axi_bvalid_d1;
                    axi_rresp <= (axi_rvalid) ? 2'b00 : axi_rresp;
                    axi_bid <= axi_bid;
        end
        default : begin
                    axi_rvalid <= 1'b0;
                    axi_bvalid <= 1'b0;
                    axi_rresp <= 2'b00;
                    axi_bid <= 2'b00;
        end
        endcase
    end
end

always @(posedge clk) begin
    if (reset) begin
        axi_rdata <= 32'h0;
        axi_bresp <= 2'b00;
    end 
    else begin
        if (axi_rvalid & axi_rready) begin
            axi_rdata <= hrdata;
            axi_bresp <= axi_bresp;
        end 
        else if (axi_bvalid & axi_bready) begin
            axi_rdata <= axi_rdata;
            axi_bresp <= axi_bresp;
        end 
        else begin
            axi_rdata <= axi_rdata;
            axi_bresp <= axi_bresp;
        end
    end
end

endmodule