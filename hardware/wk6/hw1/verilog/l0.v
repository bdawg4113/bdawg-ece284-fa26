// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  
  genvar i;

  assign o_ready = ?? ;
  assign o_full  = ?? ;


  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en[i]),
	 .wr(//which one are you going to read?
     ),
         .o_empty(...), // my_empty[7:0] -- use boolean logic to show that if the rows are all empty, then you cannot read an empty cell 
         .o_full(...),  // my_full[7:0] -- use boolean logic here because that indicates your fifo is full, you cannot write to these FIFOs 
                        
	 .in(...),
	 .out(...),
         .reset(reset));
  end


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
   end
   else

      /////////////// version1: read all row at a time ////////////////
      ...
      ///////////////////////////////////////////////////////



      //////////////// version2: read 1 row at a time /////////////////
      ...
      ///////////////////////////////////////////////////////
    end

endmodule
