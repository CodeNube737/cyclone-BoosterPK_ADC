// adcInterface_psuedo.sv
// 2/9/2025
// By: Mikhail R
// Description: Implements FSM for LTC2308 ADC interface
// 	Continuously samples the requested ADC channel and outputs the conversion result
/////////////////////////////////////////////////////////////////////////////////////
module adcInterface(
   input logic clk, reset_n,
   input logic [2:0] chan,		// ADC channel requested by user
   output logic [11:0] result,		// ADC conversion result 
   // ltc2308 signals
   output logic ADC_CONVST, ADC_SCK, ADC_SDI, // Start-adc-Conversion bit, adc-clk, adc-in
   input logic ADC_SDO // adc out (to be loaded into result)
);
 // before proceeding, please understand WHAT all of the above i/o's mean & are!!
 	// ADC_SCK: adc's external "serial data clock"
	// 	is meant to be some kind of a clock that almost always outputs to the ADC, sychronizing the data transfer.
	// 	i/o's: SDI is latched to SCK's rising edge, SDO to SCK's falling edge
	// ADC_SDI: adc's Serial Data Input. 
	// 	The SDI serial bit stream configures the ADC and is latched on the rising edge of the fi rst 6 SCK pulses.
	// 	SDI is sent from board IN to the adc to ensure signal is stable on SCK falling edge
	// ADC_SDO: Serial Data Out. 
	// 	SDO outputs the data from the previous conversion. SDO is shifted out serially on the falling edge of each SCK pulse.
	// 	SDO is sent from adc OUT to the board on rising edge of SCK
	// ADC_CONVST: Conversion Start. 
	// 	The rising edge of CONVST initiates a conversion. After the conversion is fi nished, pull CONVST low to enable the serial output (SDO).
	// 	For best performance, ensure that CONVST returns low within 40ns after the conversion starts or after the conversion ends.

 // logic:
   //The following 4 steps are to be sequentially run in an infinite loop
   // 1) input the channel to read from from "chan"
   // 2) start CONVST (1x clk-cycle HI, then 1x clk-cycle LO)
   // 		- sync with negedge of clk (not SCK)
   // 3) ***_toggle SCK like a madman_&&_output SDI config word to adc_&&_input bits from SDO to a temp_***
   // 		- SCK is not for your module, but for the ADC to sample i/o's every rising edge of SCK (assign to clk at negedge for 12 cycles)
   // 		- update SDI (output) at negedge of clk (adc will sample it at the following posedge of sck): config_word = {1'b1, chan[0], chan[2:1], 1'b1, 1'b0}; 
   // 		- update temp w/ the value of SDO at posedge of clk
   // 4) idle (LO, minimum 1 cycle) the SCK_&&_load temp into result
   // - start again

 // also, note that this module APPARENTLY doesn't work with 50MHz clks, but 50/32 = 1.5625 MHz clk...
	// this is not written in this module, but will be inplemented in the top-level module

endmodule

