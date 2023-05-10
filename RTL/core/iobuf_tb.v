module iobuf_tb();

reg     clk;
reg     I;
reg    IO;

wire    T;
wire    O;

parameter CLK_PERIOD = 10;

IOBUF IOBUF_u(
    .I          (I),
    .IO         (IO),
    .T          (T),
    .O          (O)
);

always #(CLK_PERIOD/2) clk = ~clk;
always T = 1;

initial begin
    I <= 0;
    IO <= 0;

    #1000;
    @(posedge clk);
    IO <= 1;

    #1000;
    @(posedge clk);
    IO <= 0;
    I <= 1;

    #1000;
    IO <= 1;
    I <= 1;


end