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
    output logic spkr,           // Speaker output
    output logic red, green, blue // DM LEDs
);


   logic [1:0] digit;  // select digit to display
   logic [3:0] disp_digit;  // current digit of count to display
   logic [15:0] clk_div_count; // count used to divide clock
   logic enc1_cw, enc1_ccw;  // encoder module outputs
	logic [31:0] bcd_count; // will be used for binary-to-decimal output, if completed (future work)
   // **new** //
   logic [11:0] ADC_result; // stores the current frequency being played
	
	// *********** to be completed ************** //
	
endmodule
	
	