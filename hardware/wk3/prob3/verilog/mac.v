// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c);

// Q2, regular mac. Uncomment the lines below to run Q2

// parameter bw = 4;
// parameter psum_bw = 16;

// input logic  [bw-1:0] a;                // 4 bit unsigned activations
// input logic signed [bw-1:0] b;          // 4 bit signed weights
// input logic signed [psum_bw-1:0] c;     // 16 bit signed psum_in
// output logic signed [psum_bw-1:0] out;  // 16 bit signed psum_out

// logic signed [bw:0] a_s;                // signed version of activations
// logic signed [2*bw:0] prod;             // activation * weights 

// assign a_s = {1'b0, a};                 // 5 bit signed activations 
// assign prod = a_s * b;                  // signed x signed, a_s is always >= 0
// assign out = c + prod;

// =================================================================================
// Q3, split weights MAC. Uncomment the lines below to run for Q3: 

parameter bw = 4;
parameter psum_bw = 16;

input logic  [4*bw-1:0] a;              // x3, x2, x1, x0 - each 4 bit unsigned 
input logic  [4*bw-1:0] b;              // w3, w2, w1, w0 - each 4 bit signed 
input logic signed [psum_bw-1:0] c;     // 16 bit signed psum_in
output logic signed [psum_bw-1:0] out;  // 16 bit signed psum_out

logic signed [2*bw:0] prod_0;           // x0*w0, 9 bits holds -120 to 105
logic signed [2*bw:0] prod_1;           // x1*w1
logic signed [2*bw:0] prod_2;           // x2*w2
logic signed [2*bw:0] prod_3;           // x3*w3
logic signed [psum_bw-1:0] sum;         // x0*w0 + x1*w1 + x2*w2 + x3*w3

// {1'b0, x} keeps each activation non-negative when treated as signed
assign prod_0 = $signed({1'b0, a[bw*0 +: bw]}) * $signed(b[bw*0 +: bw]);
assign prod_1 = $signed({1'b0, a[bw*1 +: bw]}) * $signed(b[bw*1 +: bw]);
assign prod_2 = $signed({1'b0, a[bw*2 +: bw]}) * $signed(b[bw*2 +: bw]);
assign prod_3 = $signed({1'b0, a[bw*3 +: bw]}) * $signed(b[bw*3 +: bw]);

assign sum = prod_0 + prod_1 + prod_2 + prod_3;

assign out = sum + c;

endmodule
