`define IDLE 2'b00
`define DRAW 2'b01
`define UPDATE 2'b10
`define END_DRAW 2'b11
`timescale 1ps/1ps

module tb_rtl_circle();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
//CLOCK & RESET
reg clk;
reg rst_n;

//INPUTS TO STATEMACHINE
logic [2:0] colour;
logic [7:0] centre_x;
logic [6:0] centre_y;
logic [7:0] radius;
logic start;

//OUTPUTS FROM STATEMACHINE
logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

//ERROR FLAG
reg err;

//COUNTER & DONE FLAG
logic [31:0] counter;
logic done_flag;

circle dut(.clk(clk), .rst_n(rst_n), .colour(colour), .centre_x(centre_x), .centre_y(centre_y), .radius(radius), .start(start), .done(done), .vga_x(vga_x), .vga_y(vga_y), .vga_colour(vga_colour), .vga_plot(vga_plot));

task step_n;
input int n;
begin
    repeat (n) @(posedge clk);
    #1;
end
endtask

task autocheck;
    input [1:0] expected_state;
    input [7:0] expected_vga_x;
    input [6:0] expected_vga_y;
    input [2:0] expected_vga_colour;
    input expected_vga_plot;
    input expected_vga_done;

     if(dut.state !== expected_state)begin
        $display("ERROR, expected state is %b but present state = %b", expected_state, dut.state);
        err = 1'b1;
    end

     if(expected_vga_x !== vga_x)begin
        $display("ERROR, expected x coordinate is %b, but current x coordinate is %b", expected_vga_x, vga_x);
        err = 1'b1;
    end

    if(expected_vga_y !== vga_y)begin
        $display("ERROR, expected y coordinate is %b, but current y coordinate is %b", expected_vga_y, vga_y);
        err = 1'b1;
    end

    if(expected_vga_colour !== vga_colour)begin
        $display("ERROR, expected colour is %b, but current colour is %b", expected_vga_colour, vga_colour);
        err = 1'b1;
    end

    if(expected_vga_plot !== vga_plot)begin
        $display("ERROR, expected vga_plot is %b, but current vga_plot is %b", expected_vga_plot, vga_plot);
        err = 1'b1;
    end 

     if(expected_vga_done !== done)begin
        $display("ERROR, expected done is %b, but current d is %b", expected_vga_done, done);
        err = 1'b1;
    end

endtask

initial begin
    clk = 0; #5;
    forever begin
        clk = 1; #5;
        clk = 0; #5;
    end
end

initial begin
    counter = 32'd0;
    done_flag = 0;
    centre_x = 8'd80;
    centre_y = 7'd60;
    radius = 8'd40;
    colour = 3'd010;
    rst_n = 0;
    start = 0;

    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
    #1;

    $display("Checking for IDLE state");
    autocheck(2'b00, 8'd0, 7'd0, 3'd0, 1'd0, 1'd0);

    start = 1;
    @(posedge clk);
    start = 0;
    #1;
    $display("Checking transition to DRAW");
    autocheck(2'b01, vga_x, vga_y, 3'b010, 1'b1, 1'b0);

    wait (dut.state == 2'b01);
    @(posedge clk);
    #1;
    $display("Entered Draw state");

    wait(dut.octant == 3'd0);
     #1;
    $display("Checking for Octant 0");
    autocheck(2'b01, dut.centre_x + dut.offset_x, dut.centre_y + dut.offset_y, dut.colour, 1'b1, 1'b0);

    wait(dut.octant == 3'd1);
     #1;
    $display("Checking for Octant 1");
    autocheck(2'b01, dut.centre_x + dut.offset_y, dut.centre_y + dut.offset_x, dut.colour, 1'b1, 1'b0);

    wait(dut.octant == 3'd2);
    #1;
    $display("Checking for Octant 2");
    autocheck(2'b01, dut.centre_x - dut.offset_x, dut.centre_y + dut.offset_y, dut.colour, 1'b1, 1'b0);

    wait(dut.octant == 3'd3);
     #1;
    $display("Checking for Octant 3");
    autocheck(2'b01, dut.centre_x - dut.offset_y, dut.centre_y + dut.offset_x, dut.colour, 1'b1, 1'b0);

    wait(dut.octant == 3'd4);
     #1;
    $display("Checking for Octant 4");
    autocheck(2'b01, dut.centre_x - dut.offset_x, dut.centre_y - dut.offset_y, dut.colour, 1'b1, 1'b0);

    wait(dut.octant == 3'd5);
     #1;
    $display("Checking for Octant 5");
    autocheck(2'b01, dut.centre_x - dut.offset_y, dut.centre_y - dut.offset_x, dut.colour, 1'b1, 1'b0);

    wait(dut.octant == 3'd6);
     #1;
    $display("Checking for Octant 6");
    autocheck(2'b01, dut.centre_x + dut.offset_x, dut.centre_y - dut.offset_y, dut.colour, 1'b1, 1'b0);

    wait(dut.octant == 3'd7);
     #1;
    $display("Checking for Octant 7");
    autocheck(2'b01, dut.centre_x + dut.offset_y, dut.centre_y - dut.offset_x, dut.colour, 1'b1, 1'b0);

    $display("Checked all 8 octants successfully");

    wait(dut.state == 2'b10);
    #1;
    $display("Transitioned to UPDATE");
    autocheck(2'b10, vga_x, vga_y, dut.colour, 1'b0, 1'b0);

    wait(dut.state == 2'b11);
     #1;
    $display("Transitioned to END_DRAW");

    start = 1'b0;
    wait (dut.state == `IDLE);
    #1;
    $display("Returned to IDLE");

    $display("Test completed");

          if (err) $display("There were errors detected");
        else $display("No errors detected");
        $stop;
end

endmodule: tb_rtl_circle
