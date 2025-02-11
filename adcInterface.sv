// adcInterface.sv
// 2/9/2025
// By: Mikhail R
// Description: Implements FSM for LTC2308 ADC interface
// 	Continuously samples the requested ADC channel and outputs the conversion result
/////////////////////////////////////////////////////////////////////////////////////
module adcInterface(
   input logic clk, reset_n,   // reset_n is active low
   input logic [2:0] chan,     // ADC channel requested by user
   output logic [11:0] result, // ADC conversion result
   output logic ADC_CONVST, ADC_SCK, ADC_SDI, // Start-adc-Conversion bit, adc-clk, adc-in
   input logic ADC_SDO         // ADC output (to be loaded into result)
);

   // State definitions
   typedef enum logic [2:0] {HOLD, CONVST_HIGH, CONVST_LOW, TRANSFER, WAIT} state_t;
   state_t state, nextState;

   logic [3:0] transferCount;  // Counts the 12 cycles of SCK
   logic [11:0] configWord;    // 6-bit config + 6-bit padding
   logic [11:0] tempResult;    // Temporary result storage

   // Next-State Logic & Combinational Outputs
   always_comb begin
      // Default values (to prevent unintended latches)
      nextState = state;
      ADC_CONVST = 0;

      case (state)
         HOLD: begin
            nextState = CONVST_HIGH;
         end
         CONVST_HIGH: begin
            nextState = CONVST_LOW;
            ADC_CONVST = 1; // Start ADC conversion
         end
         CONVST_LOW: begin
            nextState = TRANSFER;
         end
         TRANSFER: begin
            if (transferCount >= 4'd12)
               nextState = WAIT;
            else
               nextState = TRANSFER;
         end
         WAIT: begin
            nextState = CONVST_HIGH;
         end
         default: begin
            nextState = HOLD;
         end
      endcase
   end

   // State Register
   always_ff @(negedge clk or negedge reset_n) begin
      if (!reset_n) begin
         state <= HOLD;
         transferCount <= 4'b0;
         configWord <= 12'b0;
         tempResult <= 12'b0;
         result <= 12'b0;
      end else begin
         state <= nextState;

         if (state == CONVST_HIGH)
            configWord <= {1'b1, chan[0], chan[2:1], 1'b1, 1'b0, 6'b000000}; // Set configWord

         if (state == WAIT)
            transferCount <= 4'b0;
      end
   end

   always_ff @(negedge clk) begin
      if (state == CONVST_LOW) begin
         ADC_SDI <= configWord[11]; // Preload MSB immediately when CONVST goes low
      end else if (state == TRANSFER && transferCount < 12) begin
         ADC_SDI <= configWord[11 - transferCount]; // Send SDI bit at negedge clk
      end else begin
         ADC_SDI <= 0; // Ensure SDI goes low when TRANSFER ends
      end
   end

   // Capture ADC_SDO at posedge clk
   always_ff @(posedge clk) begin
      if (state == TRANSFER && transferCount < 12) begin
         tempResult[11 - transferCount] <= ADC_SDO; // Capture ADC_SDO at posedge clk
         transferCount <= transferCount + 1;
      end
      if (state == TRANSFER && transferCount == 11)
         result <= tempResult; // Update result at the end of TRANSFER
   end

   // SPI Clock (SCK) generation
   assign ADC_SCK = (state == TRANSFER) ? clk : 1'b0;

endmodule


