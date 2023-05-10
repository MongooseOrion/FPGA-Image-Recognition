module IOBUF #(

  parameter   DRIVE = 12,
  parameter   IBUF_LOW_PWR = "TRUE",
  parameter   IOSTANDARD = "DEFAULT",
  parameter   SLEW = "SLOW"

) (
  input       I,
  inout       IO,
  output      O,
  input       T
);

wire pullup;
assign pullup = (!T) ? 1'b1 : 1'b0;

wire pullup_IO;
assign pullup_IO = (!IO) ? 1'b1 : 1'b0;

wire buf_in;
assign buf_in = (I ^ pullup_IO) ? 1'b1 : 1'b0;

wire buf_out;
assign buf_out = (O & !T) | (buf_in & T);

assign IO = (buf_out ^ pullup) ? 1'b1 : 1'b0;

endmodule





