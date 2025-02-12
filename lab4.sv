// lab4.sv
// 2/11/2025
// By: Mikhail Rego
// Description: Top level module for on-board ADC project. 
// 	Displays in the result from the adcInterface module.
/////////////////////////////////////////////////////////////////
module lab4 (
   input logic CLOCK_50,        // 50 MHz clock
   (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) // needed per rotary encoder
   input logic enc1_a, enc1_b,  // Encoder 1 signals
   input logic s1, //s2,          // Push-buttons s1(reset_n), s2(obsolete)
   output logic [7:0] leds,     // 7-seg LED enables
   output logic [3:0] ct,       // Digit cathodes
   output logic red, green, blue, // DM LEDs
   output logic ADC_CONVST, ADC_SCK, ADC_SDI, // Start-adc-Conversion bit, adc-clk, adc-in
   input logic ADC_SDO         // ADC output (to be loaded into result)
);

   logic [1:0] digit;  // select digit to display
   logic [3:0] disp_digit;  // current digit of count to display
   logic [17:0] clk_div_count; // count used to divide clock
   logic enc1_cw, enc1_ccw;  // encoder module outputs
   logic [31:0] bcd_count; // will be used for binary-to-decimal output, if completed (future work)
   // **new** //
   logic [11:0] ADC_result; // stores the current frequency being played
   logic [2:0] ADC_channel;     // ADC channel requested by user
	logic [5:0] adc_clk_div;
	logic ADC_clk;

   // instantiate modules to implement design
   decode2 decode2_0 (.digit(digit), .ct(ct)) ;
   decode7 decode7_0 (.num(disp_digit), .leds(leds)) ;
   whiteOut dmLEDS (.red, .green, .blue) ; // comment out to use BP leds
   encoder encoder_1 (.clk(CLOCK_50), .a(enc1_a), .b(enc1_b), .cw(enc1_cw), .ccw(enc1_ccw), .reset_n(s1));
   // **new** //
   //enc2bcd bdc_0 ( .clk(CLOCK_50), .enc_count(freq), .bcd_count(bcd_count) );
   enc2chan channelEncoder_1 ( .clk(CLOCK_50), .reset_n(s1), .cw(enc1_cw), .ccw(enc1_ccw), .chan(ADC_channel) ) ;
   adcInterface adcInterface_0 ( 
      .clk(ADC_clk), 
      .reset_n(s1), 
      .chan(ADC_channel), 
      .result(ADC_result), 
      .ADC_CONVST(ADC_CONVST),
      .ADC_SCK(ADC_SCK),
      .ADC_SDI(ADC_SDI),
      .ADC_SDO(ADC_SDO)
   ) ;
   // **Optional BCD Conversion (Future Work)**
   // enc2bcd bcd_0 ( .clk(CLOCK_50), .enc_count(ADC_result), .bcd_count(bcd_count) );

   // use count to divide clock and generate a 2 bit digit counter to determine which digit to display
   always_ff @(posedge CLOCK_50) begin
      adc_clk_div <= adc_clk_div + 1'b1;
      ADC_clk <= adc_clk_div[5:4];  // we might have to play with this a bit
   end
	
   // use count to divide clock and generate a 2 bit digit counter to determine which digit to display
   always_ff @(posedge CLOCK_50) begin
      clk_div_count <= clk_div_count + 1'b1;
      digit <= clk_div_count[15:14];  
   end

   // Select digit to display (disp_digit) from last 4 nibbles of freq
   always_comb begin
      case (digit)
         2'b00: disp_digit = ADC_result[3:0]; // preferably, bcd_count, not freq
         2'b01: disp_digit = ADC_result[7:4]; 
         2'b10: disp_digit = ADC_result[11:8];
         2'b11: disp_digit = ADC_channel;
         default: disp_digit = 16'h0000;        // Default case (shouldn't occur)
      endcase
   end

endmodule

