`define IDLE 2'b00;
`define BEGIN_FILL 2'b10;
`define END_FILL 2'b11;
`timescale 1ps/1ps

module tb_rtl_task2();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
reg CLOCK_50;
reg [3:0] KEY;
reg [9:0] SW;

logic [7:0] VGA_X;
logic [6:0] VGA_Y;
logic [2:0] VGA_COLOUR;
logic VGA_PLOT;

reg err;

task2 dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(),  // Not used
        .HEX0(), .HEX1(), .HEX2(), .HEX3(), .HEX4(), .HEX5(),
        .VGA_R(), .VGA_G(), .VGA_B(),
        .VGA_HS(), .VGA_VS(), .VGA_CLK(),
        .VGA_X(VGA_X),
        .VGA_Y(VGA_Y),
        .VGA_COLOUR(VGA_COLOUR),
        .VGA_PLOT(VGA_PLOT)
    );

task step_n;
input int n;
begin
    repeat(n) @(posedge CLOCK_50);
    #1;
end
endtask

task autocheck;
    input [1:0] expected_state;
    input [7:0] expected_vga_x;
    input [6:0] expected_vga_y;
    input expected_done;
    input expected_plot;

    if(dut.fill_inst.state !== expected_state)begin
        $display("ERROR, expected state is %b but present state = %b", expected_state, dut.fill_inst.state);
        err = 1'b1;
    end

    if(expected_vga_x !== VGA_X)begin
        $display("ERROR, expected x coordinate is %b, but current x coordinate is %b", expected_vga_x, VGA_X);
        err = 1'b1;
    end

    if(expected_vga_y !== VGA_Y)begin
        $display("ERROR, expected y coordinate is %b, but current y coordinate is %b", expected_vga_y, VGA_Y);
        err = 1'b1;
    end

    if(expected_done !== dut.fill_inst.done)begin
        $display("ERROR, expected done is %b, but current d is %b", expected_done, dut.fill_inst.done);
        err = 1'b1;
    end

    if(expected_plot !== VGA_PLOT)begin
        $display("ERROR, expected vga_plot is %b, but current vga_plot is %b", expected_plot, VGA_PLOT);
        err = 1'b1;
    end

endtask

initial begin
    CLOCK_50 = 0; #5;
    forever begin
        CLOCK_50 = 1; #5;
        CLOCK_50 = 0; #5;
    end
end

initial begin
    KEY = 4'b0000;
    SW = 10'b0000000000;

     step_n(3);
     KEY[3] = 1;     // Release reset
     step_n(2);

     $display("Checking IDLE -> BEGIN FILL");
     step_n(1);
     autocheck(2'b10, 8'b0, 7'b0, 1'b0, 1'b1);
     $display("PASSED");

     $display("CHECKING END_FILL");
     wait(dut.fill_inst.done);
     #1;
     autocheck(2'b11, 8'd159, 7'd119, 1'b1, 1'b0);
     $display("PASSED");

    $display("Checked all the states successfully");

     if (err) $display("There were errors detected");
        else $display("No errors detected");
        $stop;

end


endmodule: tb_rtl_task2
