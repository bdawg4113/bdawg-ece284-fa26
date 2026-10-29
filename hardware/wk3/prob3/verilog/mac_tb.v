// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mac_tb;

parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;

reg  [4*bw-1:0] a;   // {x3, x2, x1, x0}
reg  [4*bw-1:0] b;   // {w3, w2, w1, w0}
reg  [psum_bw-1:0] c;
wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;

integer w_file ; // file handler
integer w_scan_file ; // file handler

integer x_file ; // file handler
integer x_scan_file ; // file handler

integer x_dec;
integer w_dec;
integer i; 
integer errors = 0;
integer u; 
integer k;
reg  [4*bw-1:0] a_tmp;
reg  [4*bw-1:0] b_tmp;

function [3:0] w_bin ;
  input integer  weight ;
  begin

    if (weight>-1)
     w_bin[3] = 0;
    else begin
     w_bin[3] = 1;
     weight = weight + 8;
    end

    if (weight>3) begin
     w_bin[2] = 1;
     weight = weight - 4;
    end
    else 
     w_bin[2] = 0;

    if (weight>1) begin
     w_bin[1] = 1;
     weight = weight - 2;
    end
    else 
     w_bin[1] = 0;

    if (weight>0) 
     w_bin[0] = 1;
    else 
     w_bin[0] = 0;

  end
endfunction


function [3:0] x_bin ;
  input integer activation ;
  begin

    // unsigned decimal-to-binary conversion, 0 to 15
    if (activation>7) begin
     x_bin[3] = 1;
     activation = activation - 8;
    end
    else
     x_bin[3] = 0;

    if (activation>3) begin
     x_bin[2] = 1;
     activation = activation - 4;
    end
    else
     x_bin[2] = 0;

    if (activation>1) begin
     x_bin[1] = 1;
     activation = activation - 2;
    end
    else
     x_bin[1] = 0;

    if (activation>0)
     x_bin[0] = 1;
    else
     x_bin[0] = 0;

  end
endfunction


// Below function is for verification
function [psum_bw-1:0] mac_predicted;
  input [4*bw-1:0] a;        // four unsigned activations, x0 in the low bits
  input [4*bw-1:0] b;        // four signed weights, w0 in the low bits
  input [psum_bw-1:0] c;     // signed psum_in

  integer a_int;
  integer b_int;
  integer c_int;
  integer m;
  begin
    c_int = c[psum_bw-1] ? (c - (1 << psum_bw)) : c;
    for (m=0; m<4; m=m+1) begin
      a_int = a[bw*m +: bw];                                 // unsigned: 0 to 15
      b_int = b[bw*m + bw-1] ? (b[bw*m +: bw] - (1 << bw))   // 2's complement: -8 to 7
                             : b[bw*m +: bw];
      c_int = c_int + a_int * b_int;                         // integer math
    end
    mac_predicted = c_int;                                   // truncated to 16 bits
  end
endfunction



mac_wrapper #(.bw(bw), .psum_bw(psum_bw)) mac_wrapper_instance (
	.clk(clk), 
        .a(a), 
        .b(b),
        .c(c),
	.out(out)
); 
 

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data
  x_file = $fopen("a_data.txt", "r");  //activation

  $dumpfile("mac_tb.vcd");
  $dumpvars(0,mac_tb);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  

  for (i=0; i<5; i=i+1) begin  // 20 entries in the data files, 4 per cycle

     #1 clk = 1'b1;
     #1 clk = 1'b0;

     // out now holds the result of the previous cycle's inputs
     if (i>0 && out !== expected_out) begin
       errors = errors + 1;
       $display("MISMATCH cycle %0d: out=%0d expected=%0d", i, $signed(out), $signed(expected_out));
     end

     // entries 4i+1..4i+4 become x0..x3 / w0..w3
     for (k=0; k<4; k=k+1) begin
       w_scan_file = $fscanf(w_file, "%d\n", w_dec);
       x_scan_file = $fscanf(x_file, "%d\n", x_dec);
       a_tmp[bw*k +: bw] = x_bin(x_dec); // unsigned number
       b_tmp[bw*k +: bw] = w_bin(w_dec); // signed number
     end
     a = a_tmp;
     b = b_tmp;
     c = expected_out;

     expected_out = mac_predicted(a, b, c);

  end



  #1 clk = 1'b1;
  #1 clk = 1'b0;

  if (out !== expected_out) begin
    errors = errors + 1;
    $display("MISMATCH last cycle: out=%0d expected=%0d", $signed(out), $signed(expected_out));
  end
  if (errors == 0) $display("PASS: out matches expected_out in every cycle");
  else $display("FAIL: %0d mismatches", errors);

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




