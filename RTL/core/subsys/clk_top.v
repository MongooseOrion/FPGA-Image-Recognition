module clk_top(
  input     clkin1,
  input     pll_rst,
  output    pll_lock,
  output    clkout0,
  output    clkout1
   );

parameter CNT_MAX = 16'd2500;               // 慢速时钟要求 32.768kHZ，而 clkout1=81920kHz，是其的 2500 倍
parameter CNT_HALF = CNT_MAX / 2;

wire        clkout1_temp;
reg         clkout1_reg;
reg  [15:0] cnt;

assign  clkout1 = clkout1_reg;

clk_wiz0 main_clk (
  .pll_rst          (pll_rst),        // input
  .clkin1           (clkin1),         // input
  .pll_lock         (pll_lock),       // output
  .clkout0          (clkout0),        // output
  .clkout1          (clkout1_temp)    // output
);

always@(posedge clkin1 or negedge pll_rst) begin
    if(!pll_rst) begin
        cnt <= 16'd0;
    end
    else if(cnt < CNT_MAX-1) begin
        cnt <= cnt + 1'b1;
    end
    else begin
        cnt <= 16'd0;
    end
end

always@(posedge clkin1 or negedge pll_rst) begin
    if(!pll_rst) begin
        clkout1_reg <= 1'b0;
    end
    else if(cnt < CNT_HALF-1) begin
        clkout1_reg <= 1'b1;
    end
    else begin
        clkout1_reg <= 1'b0;
    end
end

endmodule