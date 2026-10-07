module mac (out, A, B, format, acc, clk, reset);

parameter bw = 8;
parameter psum_bw = 16;

input clk;
input acc;
input reset;
input format;

input signed [bw-1:0] A;
input signed [bw-1:0] B;

output signed [psum_bw-1:0] out;

reg signed [psum_bw-1:0] psum_q;
reg signed [bw-1:0] a_q;
reg signed [bw-1:0] b_q;

assign out = psum_q;



// 2's-complement multiplication
wire signed [psum_bw-1:0] product_2c;

assign product_2c = a_q * b_q;


// Sign-and-magnitude multiplication
//
// a_q[7]    = sign
// a_q[6:0]  = magnitude
//
// b_q[7]    = sign
// b_q[6:0]  = magnitude

wire signed [psum_bw-1:0] product_sm;

assign product_sm =
    (a_q[bw-1] ^ b_q[bw-1])
    ?
    -(
        $signed({1'b0, a_q[bw-2:0]}) *
        $signed({1'b0, b_q[bw-2:0]})
     )
    :
    (
        $signed({1'b0, a_q[bw-2:0]}) *
        $signed({1'b0, b_q[bw-2:0]})
    );


// select product to assign to either 2's comp product or sign magnitude product 
wire signed [psum_bw-1:0] product;

assign product = format ? product_sm : product_2c;


// ADDITION: 
// format = 0:
//     psum_q is already 2's complement.
//
// format = 1:
//     psum_q is sign-and-magnitude, so convert it to a signed value.
//

wire signed [psum_bw-1:0] psum_decoded;

assign psum_decoded =
    (format == 1'b0)
    ?
    psum_q
    :
    (
        psum_q[psum_bw-1]
        ?
        -$signed({1'b0, psum_q[psum_bw-2:0]})
        :
        $signed({1'b0, psum_q[psum_bw-2:0]})
    );



// acc = 1:
//     old psum + new product
//
// acc = 0:
//     new product only
//

wire signed [psum_bw-1:0] next_sum;

assign next_sum =
    acc
    ? (psum_decoded + product)
    : product;


// atp psum_q should have the result of the multiply and addition in either 
// 2's comp or sign magnitude. Make a simple mux to assign and choose whether 
// 2's comp or sign magnitude MAC will be used.
// format = 0:
//     Store 2's-complement result.
//
// format = 1:
//     Store sign-and-magnitude result. 
//

wire [psum_bw-1:0] next_psum;

assign next_psum =
    (format == 1'b0)
    ?
    next_sum
    :
    (
        next_sum[psum_bw-1]
        ?
        {1'b1, -next_sum[psum_bw-2:0]}
        :
        {1'b0, next_sum[psum_bw-2:0]}
    );


// Wire to FF's as stated in the problem
// since it is a synchronous design 
always @(posedge clk) begin

    if (reset) begin

        psum_q <= 0;
        a_q    <= 0;
        b_q    <= 0;

    end
    else begin

        // Update the partial sum using the OLD a_q and b_q.
        psum_q <= next_psum;

        // Capture new inputs.
        a_q <= A;
        b_q <= B;

    end

end

endmodule