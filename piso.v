// PISO - Parallel In Serial Out (Shift Left & Shift Right)
module piso(
    input clk, reset,
    input load,           // 1 = load parallel data, 0 = shift
    input shift_dir,      // 0 = shift left, 1 = shift right
    input [7:0] parallel_in,
    output reg serial_out,
    output reg [7:0] reg_state
);
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            reg_state  <= 8'b0;
            serial_out <= 0;
        end
        else if(load) begin
            reg_state  <= parallel_in;  // load parallel data
            serial_out <= 0;
        end
        else begin
            if(shift_dir == 0) begin
                serial_out <= reg_state[7];           // MSB out
                reg_state  <= {reg_state[6:0], 1'b0}; // shift left
            end else begin
                serial_out <= reg_state[0];           // LSB out
                reg_state  <= {1'b0, reg_state[7:1]}; // shift right
            end
        end
    end
endmodule
