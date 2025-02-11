// enc2chan.sv
// 2/11/2025
// By: Mikhail R
// Description: Takes in cw/ccw from the encoder module, and 
//              outputs the channel select from chan-0 to chan-7
//////////////////////////////////////////////////////////////////

module enc2chan (
   input logic clk, reset_n,  // Reset (active low) and clock
   input logic cw, ccw,       // Encoder direction pulses
   output logic [2:0] chan    // Channel select (0-7)
);

   // Register for storing the channel value
   logic [2:0] chan_reg, next_chan;

   // Sequential logic: Updates the channel on clock edge
   always_ff @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         chan_reg <= 3'd0; // Start at channel 0
      end else begin
         chan_reg <= next_chan; // Update channel
      end
   end

   // Combinational logic: Determines next channel value
   always_comb begin
      next_chan = chan_reg; // Default: Maintain current channel

      if (cw && !ccw) begin // Ensuring Only One Direction Updates
         if (chan_reg < 3'd7) 
            next_chan = chan_reg + 1; // Increment on CW
      end 
      else if (ccw && !cw) begin // same, but reverse
         if (chan_reg > 3'd0) 
            next_chan = chan_reg - 1; // Decrement on CCW
      end
   end

   // Assign output
   assign chan = chan_reg;

endmodule
