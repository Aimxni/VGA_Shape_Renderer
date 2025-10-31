`define IDLE     2'b00
`define CIRCLE1  2'b01
`define CIRCLE2  2'b10
`define CIRCLE3  2'b11

module tb_rtl_reuleaux();

//CLOCK & RESET
reg clk;
reg rst_n;


// INPUTS TO STATE MACHINE
logic [2:0] colour;
logic [7:0] centre_x;
logic [6:0] centre_y;
logic [7:0] diameter;
logic start;


// OUTPUTS FROM STATE MACHINE
logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;


// ERROR
reg err;

// COUNTERS AND DONE FLAG
logic [31:0] counter;
logic done_flag;

// DUT INSTANTIATION
reuleaux dut(
    .clk(clk),
    .rst_n(rst_n),
    .colour(colour),
    .centre_x(centre_x),
    .centre_y(centre_y),
    .diameter(diameter),
    .start(start),
    .done(done),
    .vga_x(vga_x),
    .vga_y(vga_y),
    .vga_colour(vga_colour),
    .vga_plot(vga_plot)
);


// TASK: STEP_N — advance N clock cycles
task step_n;
    input int n;
    begin
        repeat (n) @(posedge clk);
        #1;
    end
endtask


// TASK: AUTOCHECK — compare expected vs actual signals
task autocheck;
    input [1:0] expected_state;
    input [7:0] expected_vga_x;
    input [6:0] expected_vga_y;
    input [2:0] expected_vga_colour;
    input expected_vga_plot;
    input expected_done;

    if(dut.state !== expected_state) begin
        $display("ERROR: expected state %b, got %b", expected_state, dut.state);
        err = 1'b1;
    end

    if(expected_vga_x !== vga_x) begin
        $display("ERROR: expected VGA_X = %d, got %d", expected_vga_x, vga_x);
        err = 1'b1;
    end

    if(expected_vga_y !== vga_y) begin
        $display("ERROR: expected VGA_Y = %d, got %d", expected_vga_y, vga_y);
        err = 1'b1;
    end

    if(expected_vga_colour !== vga_colour) begin
        $display("ERROR: expected COLOUR = %b, got %b", expected_vga_colour, vga_colour);
        err = 1'b1;
    end

    if(expected_vga_plot !== vga_plot) begin
        $display("ERROR: expected VGA_PLOT = %b, got %b", expected_vga_plot, vga_plot);
        err = 1'b1;
    end

    if(expected_done !== done) begin
        $display("ERROR: expected DONE = %b, got %b", expected_done, done);
        err = 1'b1;
    end
endtask


// CLOCK GENERATION
initial begin
    clk = 0;
    forever begin
        #5 clk = ~clk;
    end
end


// MAIN TEST SEQUENCE
initial begin
    err = 1'b0;
    counter = 32'd0;
    done_flag = 1'b0;

    // Initialize inputs
    colour    = 3'b011;
    centre_x  = 8'd80;
    centre_y  = 7'd60;
    diameter  = 8'd40;
    start     = 1'b0;
    rst_n     = 1'b0;

    // Apply reset
    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
    #1;

    
    // Check IDLE state
    $display("Checking for IDLE state");
    autocheck(`IDLE, 8'd0, 7'd0, 3'd0, 1'd0, 1'd0);

    // Start Reuleaux drawing

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    #1;
    $display("Start asserted — expecting transition to CIRCLE1");
    wait(dut.state == `CIRCLE1);
    @(posedge clk);
    #1;

    // Check CIRCLE1
    $display("Entered CIRCLE1 state");
    autocheck(`CIRCLE1, dut.c1_vga_x, dut.c1_vga_y, dut.c1_vga_colour, dut.c1_vga_plot, 1'b0);
    wait(dut.done1);
    #1;
    $display("CIRCLE1 completed, transitioning to CIRCLE2");

    // Check CIRCLE2
    wait(dut.state == `CIRCLE2);
    @(posedge clk);
    #1;
    $display("Entered CIRCLE2 state");
    autocheck(`CIRCLE2, dut.c2_vga_x, dut.c2_vga_y, dut.c2_vga_colour, dut.c2_vga_plot, 1'b0);
    wait(dut.done2);
    #1;
    $display("CIRCLE2 completed, transitioning to CIRCLE3");

    
    // Check CIRCLE3
    wait(dut.state == `CIRCLE3);
    @(posedge clk);
    #1;
    $display("Entered CIRCLE3 state");
    autocheck(`CIRCLE3, dut.c3_vga_x, dut.c3_vga_y, dut.c3_vga_colour, dut.c3_vga_plot, 1'b0);
    wait(dut.done3);
    #1;
    $display("CIRCLE3 completed");

    
    // Verify DONE and return to IDLE
    wait(dut.done);
    #1;
    $display("All circles complete — DONE asserted");
    autocheck(`CIRCLE3, vga_x, vga_y, vga_colour, 1'b0, 1'b1);

    start = 1'b0;
    wait(dut.state == `IDLE);
    #1;
    $display("Returned to IDLE state");

    
    // FINAL CHECK
    if (err) $display("TEST FAILED: Errors detected.");
    else $display("TEST PASSED: All checks successful!");

    $stop;
end

endmodule: tb_rtl_reuleaux
