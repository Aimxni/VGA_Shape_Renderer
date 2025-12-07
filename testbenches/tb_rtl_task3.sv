`define IDLE    2'b00
`define DRAW    2'b01
`define UPDATE  2'b10
`define END_DRAW 2'b11

`timescale 1ps/1ps

module tb_rtl_task3();

//CLOCK & RESET
reg CLOCK_50;
reg [3:0] KEY;
reg [9:0] SW;

//OUTPUTS 
logic [7:0] VGA_X;
logic [6:0] VGA_Y;
logic [2:0] VGA_COLOUR;
logic VGA_PLOT;

//ERROR FLAG
logic err;

// Instantiate DUT
task3 dut (
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .SW(SW),
    .LEDR(), .HEX0(), .HEX1(), .HEX2(), .HEX3(), .HEX4(), .HEX5(),
    .VGA_R(), .VGA_G(), .VGA_B(),
    .VGA_HS(), .VGA_VS(), .VGA_CLK(),
    .VGA_X(VGA_X),
    .VGA_Y(VGA_Y),
    .VGA_COLOUR(VGA_COLOUR),
    .VGA_PLOT(VGA_PLOT)
);


initial begin
    CLOCK_50 = 0;
    forever #5 CLOCK_50 = ~CLOCK_50;
end

task step_n;
    input int n;
    begin
        repeat(n) @(posedge CLOCK_50);
        #1;
    end
endtask

// AutoCheck task
task autocheck;
    input [1:0] expected_state;
    input expected_done;
    input expected_plot;

    if (dut.cir.state !== expected_state) begin
        $display("ERROR: expected state = %b, got %b", expected_state, dut.cir.state);
        err = 1'b1;
    end

    if (dut.cir.done !== expected_done) begin
        $display("ERROR: expected done = %b, got %b", expected_done, dut.cir.done);
        err = 1'b1;
    end

    if (VGA_PLOT !== expected_plot) begin
        $display("ERROR: expected VGA_PLOT = %b, got %b", expected_plot, VGA_PLOT);
        err = 1'b1;
    end
endtask

// Test sequence
initial begin
    $display("==== Starting tb_rtl_task3 simulation ====");

    err = 0;
    KEY[3] = 1'b0;
    SW = 10'b0011110010; // radius = 60, colour = green

    // Apply reset
    step_n(3);
    KEY[3] = 1'b1;
    step_n(2);

    // Check reset state
    $display("Checking for IDLE state after reset");
    autocheck(`IDLE, 1'b0, 1'b0);
    $display("PASSED");

    // Wait for DUT to start drawing
    wait (dut.cir.state == `DRAW);
    #1;
    $display("Entered DRAW state");
    autocheck(`DRAW, 1'b0, 1'b1);
    $display("PASSED");

    // Wait for UPDATE
    wait (dut.cir.state == `UPDATE);
    #1;
    $display("Entered UPDATE state");
    autocheck(`UPDATE, 1'b0, 1'b0);
    $display("PASSED");

    // Wait for END_DRAW
    wait (dut.cir.state == `END_DRAW);
    #1;
    $display("Entered END_DRAW state");
    autocheck(`END_DRAW, 1'b1, 1'b0);
    $display("PASSED");

    // Wait for return to IDLE
    wait (dut.cir.state == `IDLE);
    #1;
    $display("Returned to IDLE");
    autocheck(`IDLE, 1'b0, 1'b0);
    $display("PASSED");

    // Final summary
    if (err)
        $display("TEST FAILED: Errors detected");
    else
        $display("TEST PASSED: No errors detected");

    $stop;
end

endmodule: tb_rtl_task3
