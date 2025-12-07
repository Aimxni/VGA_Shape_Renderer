`define IDLE 2'b00;
`define BEGIN_FILL 2'b10;
`define END_FILL 2'b11;
`timescale 1ps/1ps


module tb_rtl_fillscreen();

//CLOCK & RESET
reg clk;
reg rst_n;

//INPUTS TO STATEMACHINE
logic [2:0] colour;
logic start;

//OUTPUTS FROM STATEMACHINE
logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

//ERROR FLAG
reg err;

fillscreen dut (.clk(clk), .rst_n(rst_n), .colour(colour), .start(start), .done(done), .vga_x(vga_x), .vga_y(vga_y), .vga_colour(vga_colour), .vga_plot(vga_plot));

task step_n;
input int n;
begin
    repeat(n) @(posedge clk);
    #1;
end
endtask

task autocheck;
    input [1:0] expected_state;
    input [7:0] expected_vga_x;
    input [6:0] expected_vga_y;
    input expected_done;
    input expected_plot;

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

    if(expected_done !== done)begin
        $display("ERROR, expected done is %b, but current d is %b", expected_done, done);
        err = 1'b1;
    end

    if(expected_plot !== vga_plot)begin
        $display("ERROR, expected vga_plot is %b, but current vga_plot is %b", expected_plot, vga_plot);
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
    colour = 3'b000;
    start = 1'b0;

     repeat (2) @(posedge clk);
    rst_n = 1;

    // Wait 1-2 more cycles after reset release
     @(posedge clk);
    #1;


    rst_n = 1;
    step_n(1);

    $display("Checking IDLE -> BEGIN_FILL");
    start = 1'b1;
    @(posedge clk); #1;
    autocheck(2'b10, 8'b0, 7'b0, 1'b0, 1'b1);
    $display("PASSED");

    $display("CHECKING END_FILL");
    wait(done);
    #1;
    autocheck(2'b11, 8'd159, 7'd119, 1'b1, 1'b0);
    $display("PASSED");

    $display("Checked all the states successfully");

     $display("Checking if reaching the end of the screen");
        step_n(160 * 120);
        if (done !== 1'b1)
            $display("ERROR: Done signal never asserted!");

      if (err) $display("There were errors detected");
        else $display("No errors detected");
        $stop;

end


endmodule: tb_rtl_fillscreen
