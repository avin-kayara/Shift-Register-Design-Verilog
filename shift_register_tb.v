`timescale 1ns/1ns

module shift_register_tb;

    // ---- SIPO signals ----
    reg clk, reset;
    reg serial_in, shift_dir;
    wire [7:0] sipo_out;

    // ---- PISO signals ----
    reg load;
    reg [7:0] parallel_in;
    wire piso_serial_out;
    wire [7:0] piso_state;

    // Instantiate SIPO
    sipo SIPO_inst(
        .clk(clk), .reset(reset),
        .serial_in(serial_in),
        .shift_dir(shift_dir),
        .parallel_out(sipo_out)
    );

    // Instantiate PISO
    piso PISO_inst(
        .clk(clk), .reset(reset),
        .load(load),
        .shift_dir(shift_dir),
        .parallel_in(parallel_in),
        .serial_out(piso_serial_out),
        .reg_state(piso_state)
    );

    // Clock: toggle every 5ns -> 10ns period
    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("shift_register.vcd");
        $dumpvars(0, shift_register_tb);

        // Init
        clk = 0; reset = 1; serial_in = 0;
        shift_dir = 0; load = 0; parallel_in = 8'b0;
        #10 reset = 0;

        // ============================================
        // SIPO - SHIFT LEFT
        // Serially input 1,0,1,1,0,0,1,1 -> expect 10110011
        // ============================================
        $display("\n--- SIPO Shift LEFT ---");
        shift_dir = 0;
        begin
            serial_in = 1; #10; $display("SIPO SL: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 0; #10; $display("SIPO SL: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 1; #10; $display("SIPO SL: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 1; #10; $display("SIPO SL: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 0; #10; $display("SIPO SL: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 0; #10; $display("SIPO SL: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 1; #10; $display("SIPO SL: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 1; #10; $display("SIPO SL: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
        end

        // Reset before next test
        reset = 1; #10; reset = 0;

        // ============================================
        // SIPO - SHIFT RIGHT
        // ============================================
        $display("\n--- SIPO Shift RIGHT ---");
        shift_dir = 1;
        begin
            serial_in = 1; #10; $display("SIPO SR: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 1; #10; $display("SIPO SR: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 0; #10; $display("SIPO SR: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 0; #10; $display("SIPO SR: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 1; #10; $display("SIPO SR: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 1; #10; $display("SIPO SR: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 0; #10; $display("SIPO SR: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
            serial_in = 1; #10; $display("SIPO SR: serial_in=%b -> parallel_out=%b", serial_in, sipo_out);
        end

        // Reset before PISO
        reset = 1; #10; reset = 0;

        // ============================================
        // PISO - SHIFT LEFT
        // Load 10110011, then shift out serially
        // ============================================
        $display("\n--- PISO Shift LEFT (load=10110011) ---");
        shift_dir = 0;
        parallel_in = 8'b10110011;
        load = 1; #10; load = 0;
        $display("PISO loaded: reg_state=%b", piso_state);
        for(i = 0; i < 8; i = i+1) begin
            #10;
            $display("PISO SL: serial_out=%b | reg_state=%b", piso_serial_out, piso_state);
        end

        // Reset before next PISO test
        reset = 1; #10; reset = 0;

        // ============================================
        // PISO - SHIFT RIGHT
        // Load 11001010, then shift out serially
        // ============================================
        $display("\n--- PISO Shift RIGHT (load=11001010) ---");
        shift_dir = 1;
        parallel_in = 8'b11001010;
        load = 1; #10; load = 0;
        $display("PISO loaded: reg_state=%b", piso_state);
        for(i = 0; i < 8; i = i+1) begin
            #10;
            $display("PISO SR: serial_out=%b | reg_state=%b", piso_serial_out, piso_state);
        end

        $finish;
    end

endmodule
