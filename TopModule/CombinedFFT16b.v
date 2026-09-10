// ===================================================================
// 16-BIT FIXED-POINT COMBINED 8-POINT FORWARD AND INVERSE FFT MODULE
// ===================================================================
// Author : Nigil M R
`timescale 1ns/1ps

`define FFT  1'b0
`define IFFT 1'b1

// Sub-Module : Buttterfly with W0 and W2 Twiddle Operations
module bflyOpW02 (
    input wire MODE,
    input  wire signed [17:00] inReal_A, inImag_A,
    input  wire signed [17:00] inReal_B, inImag_B,
    output wire signed [17:00] outReal_X, outImag_X,
    output wire signed [17:00] outReal_Y, outImag_Y
);

// Wires
wire signed [17:00] sumReal; 
wire signed [17:00] sumImag; 
wire signed [17:00] diffReal; 
wire signed [17:00] diffImag;

assign sumReal  = inReal_A + inReal_B;
assign sumImag  = inImag_A + inImag_B;
assign diffReal = inReal_A - inReal_B;
assign diffImag = inImag_A - inImag_B;

// Divide by 2
assign outReal_X = (MODE == `IFFT) ? {1'b0, (sumReal  >>> 1)} : {1'b0, sumReal};
assign outImag_X = (MODE == `IFFT) ? {1'b0, (sumImag  >>> 1)} : {1'b0, sumImag};
assign outReal_Y = (MODE == `IFFT) ? {1'b0, (diffReal >>> 1)} : {1'b0, diffReal};
assign outImag_Y = (MODE == `IFFT) ? {1'b0, (diffImag >>> 1)} : {1'b0, diffImag};
endmodule

// Sub-Module : Buttterfly with W1 and W3 Twiddle Operations
module bflyOpW13 (
    input wire MODE,
    input wire TWIDDLE,
    input  wire signed [17:00] inReal_A, inImag_A,
    input  wire signed [17:00] inReal_B, inImag_B,
    output wire signed [17:00] outReal_X, outImag_X,
    output wire signed [17:00] outReal_Y, outImag_Y
);

// Wires
wire signed [17:00] wire_sumM;
wire signed [17:00] wire_sumN;
wire signed [17:00] wire_sclM;
wire signed [17:00] wire_sclN;

wire signed [17:00] sumReal; 
wire signed [17:00] sumImag; 
wire signed [17:00] diffReal; 
wire signed [17:00] diffImag;

assign wire_sumM = (TWIDDLE == 0) ? (inReal_B + inImag_B) : (inImag_B - inReal_B);
assign wire_sumN = (TWIDDLE == 0) ? (inImag_B - inReal_B) : -(inReal_B + inImag_B);

bySqRootOp bySqRootOp_M (.dataIn(wire_sumM), .dataOut(wire_sclM));
bySqRootOp bySqRootOp_N (.dataIn(wire_sumN), .dataOut(wire_sclN));

assign sumReal  = inReal_A + wire_sclM;
assign sumImag  = inImag_A + wire_sclN;
assign diffReal = inReal_A - wire_sclM;
assign diffImag = inImag_A - wire_sclN;

// Divide by 2
assign outReal_X = (MODE == `IFFT) ? (sumReal  >>> 1) : sumReal;
assign outImag_X = (MODE == `IFFT) ? (sumImag  >>> 1) : sumImag;
assign outReal_Y = (MODE == `IFFT) ? (diffReal >>> 1) : diffReal;
assign outImag_Y = (MODE == `IFFT) ? (diffImag >>> 1) : diffImag;
endmodule

// Sub-Module : Shift-Add Approximate Multiply by 1/sqrt(2)
module bySqRootOp (
    input  wire signed [17:00] dataIn,
    output wire signed [17:00] dataOut
);

wire signed [17:00] wire_shift02;
wire signed [17:00] wire_shift03;
wire signed [17:00] wire_shift05;
wire signed [17:00] wire_shift07;
wire signed [17:00] wire_shift13;

assign wire_shift02 = dataIn >>> 2;
assign wire_shift03 = dataIn >>> 3;
assign wire_shift05 = dataIn >>> 5;
assign wire_shift07 = dataIn >>> 7;
assign wire_shift13 = (dataIn[12] == 1'b0) ? 15'sh0000 : (dataIn >>> 13);

assign dataOut = (dataIn + wire_shift02 + wire_shift03 + wire_shift05 + wire_shift07 + wire_shift13) >>> 1;
endmodule

// Top-Module : 8-Point Forward FFT Core
module CombinedFFT16b (
    // Inputs
    input MODE,
    input  wire signed [15:00] realIn_00, imagIn_00,
    input  wire signed [15:00] realIn_01, imagIn_01,
    input  wire signed [15:00] realIn_02, imagIn_02,
    input  wire signed [15:00] realIn_03, imagIn_03,
    input  wire signed [15:00] realIn_04, imagIn_04,
    input  wire signed [15:00] realIn_05, imagIn_05,
    input  wire signed [15:00] realIn_06, imagIn_06,
    input  wire signed [15:00] realIn_07, imagIn_07, 

    // Outputs
    output wire signed [15:00] realOut_00, imagOut_00,
    output wire signed [15:00] realOut_01, imagOut_01,
    output wire signed [15:00] realOut_02, imagOut_02,
    output wire signed [15:00] realOut_03, imagOut_03,
    output wire signed [15:00] realOut_04, imagOut_04,
    output wire signed [15:00] realOut_05, imagOut_05,
    output wire signed [15:00] realOut_06, imagOut_06,
    output wire signed [15:00] realOut_07, imagOut_07
);

// Wires : Stage 0 (Input)
wire signed [17:00] wire_stg0_00_re, wire_stg0_00_im; 
wire signed [17:00] wire_stg0_01_re, wire_stg0_01_im;
wire signed [17:00] wire_stg0_02_re, wire_stg0_02_im; 
wire signed [17:00] wire_stg0_03_re, wire_stg0_03_im;
wire signed [17:00] wire_stg0_04_re, wire_stg0_04_im; 
wire signed [17:00] wire_stg0_05_re, wire_stg0_05_im;
wire signed [17:00] wire_stg0_06_re, wire_stg0_06_im; 
wire signed [17:00] wire_stg0_07_re, wire_stg0_07_im;

// Wires : Stage 1 
wire signed [17:00] wire_stg1_00_re, wire_stg1_00_im; 
wire signed [17:00] wire_stg1_01_re, wire_stg1_01_im;
wire signed [17:00] wire_stg1_02_re, wire_stg1_02_im; 
wire signed [17:00] wire_stg1_03_re, wire_stg1_03_im;
wire signed [17:00] wire_stg1_04_re, wire_stg1_04_im; 
wire signed [17:00] wire_stg1_05_re, wire_stg1_05_im;
wire signed [17:00] wire_stg1_06_re, wire_stg1_06_im; 
wire signed [17:00] wire_stg1_07_re, wire_stg1_07_im;

// Wires : Stage 2 
wire signed [17:00] wire_stg2_00_re, wire_stg2_00_im; 
wire signed [17:00] wire_stg2_01_re, wire_stg2_01_im;
wire signed [17:00] wire_stg2_02_re, wire_stg2_02_im; 
wire signed [17:00] wire_stg2_03_re, wire_stg2_03_im;
wire signed [17:00] wire_stg2_04_re, wire_stg2_04_im; 
wire signed [17:00] wire_stg2_05_re, wire_stg2_05_im;
wire signed [17:00] wire_stg2_06_re, wire_stg2_06_im; 
wire signed [17:00] wire_stg2_07_re, wire_stg2_07_im;

// Wires : Stage 3
wire signed [17:00] wire_stg3_00_re, wire_stg3_00_im; 
wire signed [17:00] wire_stg3_01_re, wire_stg3_01_im;
wire signed [17:00] wire_stg3_02_re, wire_stg3_02_im; 
wire signed [17:00] wire_stg3_03_re, wire_stg3_03_im;
wire signed [17:00] wire_stg3_04_re, wire_stg3_04_im; 
wire signed [17:00] wire_stg3_05_re, wire_stg3_05_im;
wire signed [17:00] wire_stg3_06_re, wire_stg3_06_im; 
wire signed [17:00] wire_stg3_07_re, wire_stg3_07_im;

// Input 
assign wire_stg0_00_re = realIn_00;  assign wire_stg0_00_im = (MODE == `IFFT) ? -imagIn_00 : imagIn_00;
assign wire_stg0_01_re = realIn_01;  assign wire_stg0_01_im = (MODE == `IFFT) ? -imagIn_01 : imagIn_01;
assign wire_stg0_02_re = realIn_02;  assign wire_stg0_02_im = (MODE == `IFFT) ? -imagIn_02 : imagIn_02;
assign wire_stg0_03_re = realIn_03;  assign wire_stg0_03_im = (MODE == `IFFT) ? -imagIn_03 : imagIn_03;
assign wire_stg0_04_re = realIn_04;  assign wire_stg0_04_im = (MODE == `IFFT) ? -imagIn_04 : imagIn_04;
assign wire_stg0_05_re = realIn_05;  assign wire_stg0_05_im = (MODE == `IFFT) ? -imagIn_05 : imagIn_05;
assign wire_stg0_06_re = realIn_06;  assign wire_stg0_06_im = (MODE == `IFFT) ? -imagIn_06 : imagIn_06;
assign wire_stg0_07_re = realIn_07;  assign wire_stg0_07_im = (MODE == `IFFT) ? -imagIn_07 : imagIn_07;

// Module Instantiation
// Stage 1 
bflyOpW02 bflyOpW02_00 (.MODE(MODE), .inReal_A(wire_stg0_00_re), .inImag_A(wire_stg0_00_im), .inReal_B(wire_stg0_04_re), .inImag_B(wire_stg0_04_im), .outReal_X(wire_stg1_00_re), .outImag_X(wire_stg1_00_im), .outReal_Y(wire_stg1_01_re), .outImag_Y(wire_stg1_01_im));
bflyOpW02 bflyOpW02_01 (.MODE(MODE), .inReal_A(wire_stg0_02_re), .inImag_A(wire_stg0_02_im), .inReal_B(wire_stg0_06_re), .inImag_B(wire_stg0_06_im), .outReal_X(wire_stg1_02_re), .outImag_X(wire_stg1_02_im), .outReal_Y(wire_stg1_03_re), .outImag_Y(wire_stg1_03_im));
bflyOpW02 bflyOpW02_02 (.MODE(MODE), .inReal_A(wire_stg0_01_re), .inImag_A(wire_stg0_01_im), .inReal_B(wire_stg0_05_re), .inImag_B(wire_stg0_05_im), .outReal_X(wire_stg1_04_re), .outImag_X(wire_stg1_04_im), .outReal_Y(wire_stg1_05_re), .outImag_Y(wire_stg1_05_im));
bflyOpW02 bflyOpW02_03 (.MODE(MODE), .inReal_A(wire_stg0_03_re), .inImag_A(wire_stg0_03_im), .inReal_B(wire_stg0_07_re), .inImag_B(wire_stg0_07_im), .outReal_X(wire_stg1_06_re), .outImag_X(wire_stg1_06_im), .outReal_Y(wire_stg1_07_re), .outImag_Y(wire_stg1_07_im));

// Stage 2
bflyOpW02 bflyOpW02_04 (.MODE(MODE), .inReal_A(wire_stg1_00_re), .inImag_A(wire_stg1_00_im), .inReal_B(wire_stg1_02_re), .inImag_B(wire_stg1_02_im),        .outReal_X(wire_stg2_00_re), .outImag_X(wire_stg2_00_im), .outReal_Y(wire_stg2_02_re), .outImag_Y(wire_stg2_02_im));
bflyOpW02 bflyOpW02_05 (.MODE(MODE), .inReal_A(wire_stg1_04_re), .inImag_A(wire_stg1_04_im), .inReal_B(wire_stg1_06_re), .inImag_B(wire_stg1_06_im),        .outReal_X(wire_stg2_04_re), .outImag_X(wire_stg2_04_im), .outReal_Y(wire_stg2_06_re), .outImag_Y(wire_stg2_06_im));
bflyOpW02 bflyOpW02_06 (.MODE(MODE), .inReal_A(wire_stg1_05_re), .inImag_A(wire_stg1_05_im), .inReal_B(wire_stg1_07_im), .inImag_B(~wire_stg1_07_re+18'd1), .outReal_X(wire_stg2_05_re), .outImag_X(wire_stg2_05_im), .outReal_Y(wire_stg2_07_re), .outImag_Y(wire_stg2_07_im));
bflyOpW02 bflyOpW02_07 (.MODE(MODE), .inReal_A(wire_stg1_01_re), .inImag_A(wire_stg1_01_im), .inReal_B(wire_stg1_03_im), .inImag_B(~wire_stg1_03_re+18'd1), .outReal_X(wire_stg2_01_re), .outImag_X(wire_stg2_01_im), .outReal_Y(wire_stg2_03_re), .outImag_Y(wire_stg2_03_im));

// Stage 3 (Not in Order)
bflyOpW02 bflyOpW02_09 (.MODE(MODE), .inReal_A(wire_stg2_00_re), .inImag_A(wire_stg2_00_im), .inReal_B(wire_stg2_04_re), .inImag_B(wire_stg2_04_im),        .outReal_X(wire_stg3_00_re), .outImag_X(wire_stg3_00_im), .outReal_Y(wire_stg3_04_re), .outImag_Y(wire_stg3_04_im));
bflyOpW02 bflyOpW02_10 (.MODE(MODE), .inReal_A(wire_stg2_02_re), .inImag_A(wire_stg2_02_im), .inReal_B(wire_stg2_06_im), .inImag_B(~wire_stg2_06_re+18'd1), .outReal_X(wire_stg3_02_re), .outImag_X(wire_stg3_02_im), .outReal_Y(wire_stg3_06_re), .outImag_Y(wire_stg3_06_im));
bflyOpW13 bflyOpW13_01 (.MODE(MODE), .TWIDDLE(1'b0), .inReal_A(wire_stg2_01_re), .inImag_A(wire_stg2_01_im), .inReal_B(wire_stg2_05_re), .inImag_B(wire_stg2_05_im), .outReal_X(wire_stg3_01_re), .outImag_X(wire_stg3_01_im), .outReal_Y(wire_stg3_05_re), .outImag_Y(wire_stg3_05_im));
bflyOpW13 bflyOpW13_02 (.MODE(MODE), .TWIDDLE(1'b1), .inReal_A(wire_stg2_03_re), .inImag_A(wire_stg2_03_im), .inReal_B(wire_stg2_07_re), .inImag_B(wire_stg2_07_im), .outReal_X(wire_stg3_03_re), .outImag_X(wire_stg3_03_im), .outReal_Y(wire_stg3_07_re), .outImag_Y(wire_stg3_07_im));

// Output
assign realOut_00 = wire_stg3_00_re[15:00];  assign imagOut_00 = (MODE == `IFFT) ? -wire_stg3_00_im[15:00] : wire_stg3_00_im[15:00];
assign realOut_01 = wire_stg3_01_re[15:00];  assign imagOut_01 = (MODE == `IFFT) ? -wire_stg3_01_im[15:00] : wire_stg3_01_im[15:00];
assign realOut_02 = wire_stg3_02_re[15:00];  assign imagOut_02 = (MODE == `IFFT) ? -wire_stg3_02_im[15:00] : wire_stg3_02_im[15:00];
assign realOut_03 = wire_stg3_03_re[15:00];  assign imagOut_03 = (MODE == `IFFT) ? -wire_stg3_03_im[15:00] : wire_stg3_03_im[15:00];
assign realOut_04 = wire_stg3_04_re[15:00];  assign imagOut_04 = (MODE == `IFFT) ? -wire_stg3_04_im[15:00] : wire_stg3_04_im[15:00];
assign realOut_05 = wire_stg3_05_re[15:00];  assign imagOut_05 = (MODE == `IFFT) ? -wire_stg3_05_im[15:00] : wire_stg3_05_im[15:00];
assign realOut_06 = wire_stg3_06_re[15:00];  assign imagOut_06 = (MODE == `IFFT) ? -wire_stg3_06_im[15:00] : wire_stg3_06_im[15:00];
assign realOut_07 = wire_stg3_07_re[15:00];  assign imagOut_07 = (MODE == `IFFT) ? -wire_stg3_07_im[15:00] : wire_stg3_07_im[15:00];
endmodule
