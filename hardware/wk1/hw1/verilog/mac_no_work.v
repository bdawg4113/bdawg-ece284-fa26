// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, A, B, format, acc, clk, reset);


//This MAC didn't work for a variety of reasons: 

// 1. Did not properly separate signed 2's complement from the signed-magnitude interpretation 
// 2. Did not 
/*
Assumptions: 

- no overflow occurs 
- hardware efficiency does not matter 
*/
parameter bw = 8;
parameter psum_bw = 16;

input clk;
input acc;
input reset;
input format;

input signed [bw-1:0] A;
input signed [bw-1:0] B;

output signed [psum_bw-1:0] out;

// added these wires to track sign and magnitudes of A and B
wire [bw-1:0] mag_a;
wire  [bw-1:0] mag_b;
wire sign_a; 
wire sign_b;

// signed magnitude multiplication: 
        // magnitudes: 
        assign mag_a = A[bw-1:0]; 
        assign mag_b = B[bw-1:0];

        //signs: 
        assign sign_a = A[bw-1];
        assign sign_b = B[bw-1];

reg signed [psum_bw-1:0] psum_q;
reg signed [bw-1:0] a_q;
reg signed [bw-1:0] b_q;

assign out = psum_q;

// Your code goes here

// signed mag: 
always @* begin 
    if (format == 1'b0) begin 
        psum_q = a_q * b_q;
    end else begin 
        // multiply signs: 
        if (sign_a ^ sign_b) begin 
            psum_q = -1 * (mag_a * mag_b);
        end else begin 
            psum_q = mag_a * mag_b;
        end
    end
end
        


always @(posedge clk) begin 
    if (reset) begin 
        psum_q <= 0; 
        a_q <= 0;
        b_q <= 0;
    end else begin 
        if (acc) begin 
            psum_q <= psum_q + a_q * b_q;
        end else begin 
            psum_q <= a_q * b_q;
        end 
        a_q <= A;
        b_q <= B;
    end
end


endmodule
