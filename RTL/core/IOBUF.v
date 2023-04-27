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

reg     O_reg;

assign  IO = T ? 1'bz : 0;
assign  O = O_reg;

always @(negedge T) begin
  O_reg <= I;
end

endmodule