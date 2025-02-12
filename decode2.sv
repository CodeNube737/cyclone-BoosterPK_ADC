// File: decode2.sv
// Description: This is a 2-to-4 decoder. It takes a 2-bit input digit and outputs a 4-bit active-low signal ct.
// Author: Mikhail Rego, with the help of open-AI
// Date: 2025-01-20

module decode2 (
  input  logic [1:0] digit,	// 2-bit input
  output logic [3:0] ct			// 4-bit active-low output for enabling
);
always_comb begin
    case (digit)
      2'b00: ct = 4'b1110;		// Enable digit 0
      2'b01: ct = 4'b1101;		// Enable digit 1
      2'b10: ct = 4'b1011;		// Enable digit 2
      2'b11: ct = 4'b0111;		// Enable digit 3
      default: ct = 4'b1111;	// Default to all inactive
    endcase
  end
endmodule
