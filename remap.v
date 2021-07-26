module INV(input I, output O);

LUT1 #(.INIT(2'b01)) _TECHMAP_REPLACE_ (.I0(I), .O(O));

endmodule

module BUF(input I, output O);

LUT1 #(.INIT(2'b10)) _TECHMAP_REPLACE_ (.I0(I), .O(O));

endmodule

module FD(input C, input D, output Q);

parameter INIT = 1'b0;

FDRE #(.INIT(INIT)) _TECHMAP_REPLACE_ (.C(C), .D(D), .CE(1'b1), .R(1'b0), .Q(Q));

endmodule

module OBUFDS(input I, output O, output OB);

parameter CAPACITANCE = "DONT_CARE";
parameter IOSTANDARD = "DEFAULT";
parameter SLEW = "SLOW";

OBUFTDS #(.CAPACITANCE(CAPACITANCE), .IOSTANDARD(IOSTANDARD), .SLEW(SLEW)) _TECHMAP_REPLACE_ (.I(I), .T(1'b0), .O(O), .OB(OB));
endmodule