module e203_system_top(

  input           clkin1,
  input           globalrst,


  // Dedicated QSPI interface
  output          qspi0_cs,
  output          qspi0_sck,
  inout   [3:0]   qspi0_dq,
                           
  //gpioA
  inout   [31:0]  gpioA,//GPIOA00~GPIOA31

  //gpioB
  inout   [31:0]  gpioB,//GPIOB00~GPIOB31

  //JTAG
  inout           mcu_TDO,//MCU_TDO-N17
  inout           mcu_TCK,//MCU_TCK-P15 
  inout           mcu_TDI,//MCU_TDI-T18
  inout           mcu_TMS,//MCU_TMS-P17

  //pmu_wakeup
  inout           pmu_paden,  //PMU_VDDPADEN-U15
  inout           pmu_padrst, //PMU_VADDPARST_V15
  inout           mcu_wakeup,  //MCU_WAKE-N15

  // vision system
    //cmos1
    inout                                cmos1_scl            ,//cmos1 i2c 
    inout                                cmos1_sda            ,//cmos1 i2c 
    input                                cmos1_vsync          ,//cmos1 vsync
    input                                cmos1_href           ,//cmos1 hsync refrence,data valid
    input                                cmos1_pclk           ,//cmos1 pxiel clock
    input   [7:0]                        cmos1_data           ,//cmos1 data
    output                               cmos1_reset          ,//cmos1 reset
    //cmos2
    inout                                cmos2_scl            ,//cmos2 i2c 
    inout                                cmos2_sda            ,//cmos2 i2c 
    input                                cmos2_vsync          ,//cmos2 vsync
    input                                cmos2_href           ,//cmos2 hsync refrence,data valid
    input                                cmos2_pclk           ,//cmos2 pxiel clock
    input   [7:0]                        cmos2_data           ,//cmos2 data
    output                               cmos2_reset          ,//cmos2 reset
    //HDMI_OUT
    output                               pix_clk                   ,//pixclk                           
    output                               vs_out                    , 
    output                               hs_out                    , 
    output                               de_out                    ,
    output  [7:0]                        r_out                     , 
    output  [7:0]                        g_out                     , 
    output  [7:0]                        b_out         
);

wire          hfextclk;
wire          lfextclk;

// All wires connected to the chip top
wire          dut_clock;
wire          dut_reset;
wire          pll_lock;

wire          dut_io_pads_jtag_TCK_i_ival;
wire          dut_io_pads_jtag_TMS_i_ival;
wire          dut_io_pads_jtag_TMS_o_oval;
wire          dut_io_pads_jtag_TMS_o_oe;
wire          dut_io_pads_jtag_TMS_o_ie;
wire          dut_io_pads_jtag_TMS_o_pue;
wire          dut_io_pads_jtag_TMS_o_ds;
wire          dut_io_pads_jtag_TDI_i_ival;
wire          dut_io_pads_jtag_TDO_o_oval;
wire          dut_io_pads_jtag_TDO_o_oe;

wire [32-1:0] dut_io_pads_gpioA_i_ival;
wire [32-1:0] dut_io_pads_gpioA_o_oval;
wire [32-1:0] dut_io_pads_gpioA_o_oe;

wire [32-1:0] dut_io_pads_gpioB_i_ival;
wire [32-1:0] dut_io_pads_gpioB_o_oval;
wire [32-1:0] dut_io_pads_gpioB_o_oe;

wire          dut_io_pads_qspi0_sck_o_oval;
wire          dut_io_pads_qspi0_cs_0_o_oval;
wire          dut_io_pads_qspi0_dq_0_i_ival;
wire          dut_io_pads_qspi0_dq_0_o_oval;
wire          dut_io_pads_qspi0_dq_0_o_oe;
wire          dut_io_pads_qspi0_dq_1_i_ival;
wire          dut_io_pads_qspi0_dq_1_o_oval;
wire          dut_io_pads_qspi0_dq_1_o_oe;
wire          dut_io_pads_qspi0_dq_2_i_ival;
wire          dut_io_pads_qspi0_dq_2_o_oval;
wire          dut_io_pads_qspi0_dq_2_o_oe;
wire          dut_io_pads_qspi0_dq_3_i_ival;
wire          dut_io_pads_qspi0_dq_3_o_oval;
wire          dut_io_pads_qspi0_dq_3_o_oe;

wire          iobuf_dwakeup_o;
wire          dut_io_pads_aon_erst_n_i_ival;
wire          dut_io_pads_aon_pmu_dwakeup_n_i_ival;
wire          dut_io_pads_aon_pmu_vddpaden_o_oval;
wire          dut_io_pads_aon_pmu_vddpaden_i_ival;
wire          dut_io_pads_aon_pmu_padrst_o_oval ;
wire          dut_io_pads_bootrom_n_i_ival;
wire          dut_io_pads_dbgmode0_n_i_ival;
wire          dut_io_pads_dbgmode1_n_i_ival;
wire          dut_io_pads_dbgmode2_n_i_ival;

wire [3:0]    qspi0_ui_dq_o; 
wire [3:0]    qspi0_ui_dq_oe;
wire [3:0]    qspi0_ui_dq_i;

wire          iobuf_jtag_TCK_o;
wire          iobuf_jtag_TMS_o;
wire          iobuf_jtag_TDI_o;
wire          iobuf_jtag_TDO_o;

// JTAG
assign dut_io_pads_jtag_TMS_i_ival = iobuf_jtag_TMS_o;
assign dut_io_pads_jtag_TCK_i_ival = iobuf_jtag_TCK_o; 
assign dut_io_pads_jtag_TDI_i_ival = iobuf_jtag_TDI_o;

// Use the LEDs for some more useful debugging things.
assign pmu_paden  = dut_io_pads_aon_pmu_vddpaden_o_oval;  
assign pmu_padrst = dut_io_pads_aon_pmu_padrst_o_oval;		

// model select
assign dut_io_pads_bootrom_n_i_ival  = 1'b1;
assign dut_io_pads_dbgmode0_n_i_ival = 1'b1;
assign dut_io_pads_dbgmode1_n_i_ival = 1'b1;
assign dut_io_pads_dbgmode2_n_i_ival = 1'b1;

assign dut_io_pads_aon_pmu_dwakeup_n_i_ival = (~iobuf_dwakeup_o);

assign dut_io_pads_aon_pmu_vddpaden_i_ival = 1'b1;

assign qspi0_sck = dut_io_pads_qspi0_sck_o_oval;
assign qspi0_cs  = dut_io_pads_qspi0_cs_0_o_oval;
assign qspi0_ui_dq_o = {
  dut_io_pads_qspi0_dq_3_o_oval,
  dut_io_pads_qspi0_dq_2_o_oval,
  dut_io_pads_qspi0_dq_1_o_oval,
  dut_io_pads_qspi0_dq_0_o_oval
};
assign qspi0_ui_dq_oe = {
  dut_io_pads_qspi0_dq_3_o_oe,
  dut_io_pads_qspi0_dq_2_o_oe,
  dut_io_pads_qspi0_dq_1_o_oe,
  dut_io_pads_qspi0_dq_0_o_oe
};
assign dut_io_pads_qspi0_dq_0_i_ival = qspi0_ui_dq_i[0];
assign dut_io_pads_qspi0_dq_1_i_ival = qspi0_ui_dq_i[1];
assign dut_io_pads_qspi0_dq_2_i_ival = qspi0_ui_dq_i[2];
assign dut_io_pads_qspi0_dq_3_i_ival = qspi0_ui_dq_i[3];


//=================================================
// Global Clock

clk_top u_e203_clk(
  .pll_rst            (globalrst),      
  .clkin1             (clkin1),      
  .pll_lock           (pll_lock),     
  .clk16mhz           (hfextclk),    
  .clk32khz           (lfextclk),
  .clkout2            (clkout2),
  .clkout3            (clkout3),
  .clkout4            (clkout4)
);


//=================================================
// SPI0 Interface


PULLUP qspi0_pullup[3:0] (
  .O      (qspi0_dq)
);

IOBUF qspi0_iobuf[3:0] (
  .IO     (qspi0_dq),
  .O      (qspi0_ui_dq_i),
  .I      (qspi0_ui_dq_o),
  .T      (~qspi0_ui_dq_oe)
);


//=================================================
// IOBUF instantiation for GPIOs

IOBUF #(
  .DRIVE          (12),
  .IBUF_LOW_PWR   ("TRUE"),
  .IOSTANDARD     ("DEFAULT"),
  .SLEW           ("SLOW")
) gpioA_iobuf[31:0] (
  .O              (dut_io_pads_gpioA_i_ival),
  .IO             (gpioA),
  .I              (dut_io_pads_gpioA_o_oval),
  .T              (~dut_io_pads_gpioA_o_oe)
);

IOBUF #(
  .DRIVE        (12),
  .IBUF_LOW_PWR ("TRUE"),
  .IOSTANDARD   ("DEFAULT"),
  .SLEW         ("SLOW")
) gpioB_iobuf[31:0] (
  .O            (dut_io_pads_gpioB_i_ival),
  .IO           (gpioB),
  .I            (dut_io_pads_gpioB_o_oval),
  .T            (~dut_io_pads_gpioB_o_oe)
);
  
//=================================================
// JTAG IOBUFs

IOBUF #(
  .DRIVE        (12),
  .IBUF_LOW_PWR ("TRUE"),
  .IOSTANDARD   ("DEFAULT"),
  .SLEW         ("SLOW")
) IOBUF_jtag_TCK (
  .O            (iobuf_jtag_TCK_o),
  .IO           (mcu_TCK),
  .I            (1'b0),
  .T            (1'b1)
);

PULLUP pullup_TCK (.O(mcu_TCK));


IOBUF #(
  .DRIVE        (12),
  .IBUF_LOW_PWR ("TRUE"),
  .IOSTANDARD   ("DEFAULT"),
  .SLEW         ("SLOW")
) IOBUF_jtag_TMS (
  .O            (iobuf_jtag_TMS_o),
  .IO           (mcu_TMS),
  .I            (1'b0),
  .T            (1'b1)
);

PULLUP pullup_TMS (.O(mcu_TMS));


IOBUF #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
) IOBUF_jtag_TDI (
    .O(iobuf_jtag_TDI_o),
    .IO(mcu_TDI),
    .I(1'b0),
    .T(1'b1)
  );

PULLUP pullup_TDI (.O(mcu_TDI));


IOBUF #(
  .DRIVE        (12),
  .IBUF_LOW_PWR ("TRUE"),
  .IOSTANDARD   ("DEFAULT"),
  .SLEW         ("SLOW")
) IOBUF_jtag_TDO (
  .O            (iobuf_jtag_TDO_o),
  .IO           (mcu_TDO),
  .I            (dut_io_pads_jtag_TDO_o_oval),
  .T            (~dut_io_pads_jtag_TDO_o_oe)
  );

  //wire iobuf_jtag_TRST_n_o;
  //IOBUF
  //#(
  //  .DRIVE(12),
  //  .IBUF_LOW_PWR("TRUE"),
  //  .IOSTANDARD("DEFAULT"),
  //  .SLEW("SLOW")
  //)


e203_soc_top u_e203_soc_top (
  //.hfextclk(clk_16M),
  .hfxoscen                         (),

  //.lfextclk(CLK32768KHZ), 
  .lfxoscen                         (),

  // Note: this is the real SoC top AON domain slow clock
  .io_pads_jtag_TCK_i_ival          (dut_io_pads_jtag_TCK_i_ival),
  .io_pads_jtag_TMS_i_ival          (dut_io_pads_jtag_TMS_i_ival),
  .io_pads_jtag_TDI_i_ival          (dut_io_pads_jtag_TDI_i_ival),
  .io_pads_jtag_TDO_o_oval          (dut_io_pads_jtag_TDO_o_oval),
  .io_pads_jtag_TDO_o_oe            (dut_io_pads_jtag_TDO_o_oe),

  .io_pads_gpioA_i_ival             (dut_io_pads_gpioA_i_ival),
  .io_pads_gpioA_o_oval             (dut_io_pads_gpioA_o_oval),
  .io_pads_gpioA_o_oe               (dut_io_pads_gpioA_o_oe),

  .io_pads_gpioB_i_ival             (dut_io_pads_gpioB_i_ival),
  .io_pads_gpioB_o_oval             (dut_io_pads_gpioB_o_oval),
  .io_pads_gpioB_o_oe               (dut_io_pads_gpioB_o_oe),

  .io_pads_qspi0_sck_o_oval         (dut_io_pads_qspi0_sck_o_oval),
  .io_pads_qspi0_cs_0_o_oval        (dut_io_pads_qspi0_cs_0_o_oval),

  .io_pads_qspi0_dq_0_i_ival        (dut_io_pads_qspi0_dq_0_i_ival),
  .io_pads_qspi0_dq_0_o_oval        (dut_io_pads_qspi0_dq_0_o_oval),
  .io_pads_qspi0_dq_0_o_oe          (dut_io_pads_qspi0_dq_0_o_oe),
  .io_pads_qspi0_dq_1_i_ival        (dut_io_pads_qspi0_dq_1_i_ival),
  .io_pads_qspi0_dq_1_o_oval        (dut_io_pads_qspi0_dq_1_o_oval),
  .io_pads_qspi0_dq_1_o_oe          (dut_io_pads_qspi0_dq_1_o_oe),
  .io_pads_qspi0_dq_2_i_ival        (dut_io_pads_qspi0_dq_2_i_ival),
  .io_pads_qspi0_dq_2_o_oval        (dut_io_pads_qspi0_dq_2_o_oval),
  .io_pads_qspi0_dq_2_o_oe          (dut_io_pads_qspi0_dq_2_o_oe),
  .io_pads_qspi0_dq_3_i_ival        (dut_io_pads_qspi0_dq_3_i_ival),
  .io_pads_qspi0_dq_3_o_oval        (dut_io_pads_qspi0_dq_3_o_oval),
  .io_pads_qspi0_dq_3_o_oe          (dut_io_pads_qspi0_dq_3_o_oe),


  // Note: this is the real SoC top level reset signal
  .io_pads_aon_erst_n_i_ival        (globalrst),
  .io_pads_aon_pmu_dwakeup_n_i_ival (dut_io_pads_aon_pmu_dwakeup_n_i_ival),
  .io_pads_aon_pmu_vddpaden_o_oval  (dut_io_pads_aon_pmu_vddpaden_o_oval),

  .io_pads_aon_pmu_padrst_o_oval    (dut_io_pads_aon_pmu_padrst_o_oval ),

  .io_pads_bootrom_n_i_ival         (dut_io_pads_bootrom_n_i_ival),

  .io_pads_dbgmode0_n_i_ival        (dut_io_pads_dbgmode0_n_i_ival),
  .io_pads_dbgmode1_n_i_ival        (dut_io_pads_dbgmode1_n_i_ival),
  .io_pads_dbgmode2_n_i_ival        (dut_io_pads_dbgmode2_n_i_ival),

  // Note: vision system
    .r_out          (r_out),
    .g_out          (g_out),
    .b_out          (b_out),
    .de_out         (de_out),
    .hs_out         (hs_out),
    .vs_out         (vs_out),
    .pix_clk        (pix_clk),

    .cmos1_data     (cmos1_data),
    .cmos1_scl      (cmos1_scl),
    .cmos1_sda      (cmos1_sda),
    .cmos1_reset    (cmos1_reset),
    .cmos1_href     (cmos1_href),
    .cmos1_pclk     (cmos1_pclk),
    .cmos1_vsync    (cmos1_vsync),

    .cmos2_data     (cmos2_data),
    .cmos2_scl      (cmos2_scl),
    .cmos2_sda      (cmos2_sda),
    .cmos2_reset    (cmos2_reset),
    .cmos2_href     (cmos2_href),
    .cmos2_pclk     (cmos2_pclk),
    .cmos2_vsync    (cmos2_vsync)  
);

// Assign reasonable values to otherwise unconnected inputs to chip top

IOBUF #(
  .DRIVE        (12),
  .IBUF_LOW_PWR ("TRUE"),
  .IOSTANDARD   ("DEFAULT"),
  .SLEW         ("SLOW")
) IOBUF_dwakeup_n (
  .O            (iobuf_dwakeup_o),
  .IO           (mcu_wakeup),
  .I            (1'b1),
  .T            (1'b1)
);



endmodule