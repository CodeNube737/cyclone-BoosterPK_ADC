// File: encoder.sv
// Description: This module takes in a clk-input and two values, 90-deg shifted, from a rotary device. 
//              It determines which value changes first and outputs cw/ccw after every 4 turns.
// Author: Mikhail Rego
// Date: 2025-01-27
///////////////////////////////////////////////////////////////////////////////////////////
// 2/11/2025
// Edited By: Mikhail R to output every 4 turns of the encoder (which is one click of the dial)
///////////////////////////////////////////////////////////////////////////////////////////
module encoder(
    input logic a, b, clk, reset_n,   // Inputs: a, b from encoder, clock signal, active-low reset
    output logic cw, ccw              // Outputs: CW and CCW pulses (1 cycle after 4 transitions)
);

    // Internal state registers
    logic [1:0] state, prev_state;
    logic idle;
    logic [2:0] cw_count, ccw_count; // 3-bit counters (counts up to 4)
    logic [3:0] debounce_counter;    // 4-bit debounce counter (adjustable)

    // Threshold for debouncing (adjustable)
    localparam DEBOUNCE_THRESHOLD = 4'd10; // Increase for more debounce delay

    // Sequential logic block to update previous states and counters
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin 
            state      <= 2'b00;
            prev_state <= 2'b00;
            cw_count   <= 3'b000;
            ccw_count  <= 3'b000;
            debounce_counter <= 4'b0000;
            cw         <= 1'b0;
            ccw        <= 1'b0;
        end else begin
            prev_state <= state;  // Save the previous state
            state      <= {a, b}; // Update the current state

            // Default outputs to 0 unless a full rotation is detected
            cw  <= 1'b0;
            ccw <= 1'b0;

            // Debounce counter increments while the state is stable
            if (state == prev_state) begin
                if (debounce_counter < DEBOUNCE_THRESHOLD)
                    debounce_counter <= debounce_counter + 4'b0001;
            end else begin
                debounce_counter <= 4'b0000; // Reset debounce counter on change
            end

            // Register valid transitions **only after debounce delay**
            if (debounce_counter >= DEBOUNCE_THRESHOLD) begin
                case ({state, prev_state})
                    // Clockwise rotation patterns
                    4'b1000, 4'b1110, 4'b0111, 4'b0001: begin
                        ccw_count <= 3'b000; // Reset CCW counter
                        if (cw_count == 3'b011) begin // 4th transition
                            cw_count <= 3'b000; // Reset CW counter
                            ccw_count <= 3'b000; // Reset CCW counter
                            cw <= 1'b1; // Output CW pulse for 1 clock cycle
                        end else begin
                            cw_count <= cw_count + 3'd1; // Increment CW counter
                        end
                    end

                    // Counterclockwise rotation patterns
                    4'b1011, 4'b0010, 4'b0100, 4'b1101: begin
                        cw_count <= 3'b000; // Reset CW counter
                        if (ccw_count == 3'b011) begin // 4th transition
                            ccw_count <= 3'b000; // Reset CCW counter
                            cw_count <= 3'b000; // Reset CW counter
                            ccw <= 1'b1; // Output CCW pulse for 1 clock cycle
                        end else begin
                            ccw_count <= ccw_count + 3'd1; // Increment CCW counter
                        end
                    end
                endcase
            end
        end
    end

    // Combinational logic block to determine if encoder is idle
    always_comb begin
        idle = (state == prev_state); // Set idle to true if state hasn't changed
    end

endmodule
