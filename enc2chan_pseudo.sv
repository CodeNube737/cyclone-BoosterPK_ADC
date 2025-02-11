// enc2chan.sv
// 2/11/2025
// By: Mikhail R
// Description: takes-in cw/ccw from the encoder module, and 
// 	outputs the channel select from chan-0 to chan-7
//////////////////////////////////////////////////////////////////
module enc2chan (
input logic clk, reset_n, // reset_n is active low
 input logic cw, ccw,
 output logic chan
);
// start on channel 0, 
// increment on cw
// decrement on ccw
// never go outside 0-7
endmodule 