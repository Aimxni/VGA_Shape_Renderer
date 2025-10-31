`define IDLE 2'b00
`define CIRCLE1 2'b01
`define CIRCLE2 2'b10
`define CIRCLE3 2'b11

`timescale 1ps/1ps

module tb_rtl_task4();

reg CLOCK_50;
reg [3:0] KEY;
reg [9:0] SW;

logic [7:0] VGA_X;
logic [6:0] VGA_Y;
logic [2:0] VGA_COLOUR;
logic VGA_PLOT;

logic err;

task4 dut (
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

// Clock stepping
task step_n;
input int n;
begin
    repeat(n) @(posedge CLOCK_50);
    #1;
end
endtask

// Autocheck task
task autocheck;
    input [1:0] expected_state;
    input expected_done;
    input expected_plot;
    
    if(dut.cir.state !== expected_state) begin
        $display("ERROR: expected state = %b, got %b", expected_state, dut.cir.state);
        err = 1'b1;
    end
    
    if(expected_done !== dut.cir.done) begin
        $display("ERROR: expected done = %b, got %b", expected_done, dut.cir.done);
        err = 1'b1;
    end
    
    if(expected_plot !== VGA_PLOT) begin
        $display("ERROR: expected vga_plot = %b, got %b", expected_plot, VGA_PLOT);
        err = 1'b1;
    end
endtask

// Clock generator
initial begin
    CLOCK_50 = 0;
    forever begin
        #5 CLOCK_50 = ~CLOCK_50;
    end
end

// Test sequence
initial begin
    KEY[3] = 1'b0; 
    SW = 10'b0101000010; //diamater = 80 // colout = green 
    err = 0;
    
    step_n(3);
    KEY[3] = 1;     
    step_n(2);
    
    $display("Checking IDLE -> CIRCLE1");
    step_n(1);
    autocheck(`CIRCLE1, 1'b0, 1'b1);
    $display("PASSED");

    $display("Checking CIRCLE2 transition");
    wait(dut.cir.state == `CIRCLE2);
    #1;
    autocheck(`CIRCLE2, 1'b0, 1'b1);
    $display("PASSED");

    $display("Checking CIRCLE3 transition");
    wait(dut.cir.state == `CIRCLE3);
    #1;
    autocheck(`CIRCLE3, 1'b0, 1'b1);
    $display("PASSED");

    $display("Checking final done state");
    wait(dut.cir.done);
    #1;
    autocheck(`CIRCLE3, 1'b1, 1'b0);
    $display("PASSED");

    if (err) $display("Some errors detected.");
    else $display("No errors detected.");
    $stop;
end

endmodule: tb_rtl_task4
