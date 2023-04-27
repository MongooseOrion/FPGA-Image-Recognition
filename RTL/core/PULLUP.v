module PULLUP(
  input  I,
  output O
);

assign O = I ? 1'b1 : 1'bz;

endmodule