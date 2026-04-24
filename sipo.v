// SIPO - Serial In Parallel Out (Shift Left & Shift Right)
module sipo(
    input clk, reset,
    input serial_in,
    input shift_dir,      // 0 = shift left, 1 = shift right
    output reg [7:0] parallel_out
);
    always @(posedge clk or posedge reset) begin
        if(reset)
            parallel_out <= 8'b0;
        else if(shift_dir == 0)
            parallel_out <= {parallel_out[6:0], serial_in};  // shift left
        else
            parallel_out <= {serial_in, parallel_out[7:1]};  // shift right
    end
endmodule
