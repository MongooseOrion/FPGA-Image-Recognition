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

assign O = T ? IO : I;
assign IO = ~T ? I : 1'bz;
    

endmodule

