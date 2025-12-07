`timescale 1ps/1ps
module tb_syn_task3();

logic CLOCK_50;
logic [3:0] KEY;
logic [9:0] SW;
logic [9:0] LEDR;
logic [6:0] HEX0;
logic [6:0] HEX1;
logic [6:0] HEX2;
logic [6:0] HEX3;
logic [6:0] HEX4;
logic [6:0] HEX5;
logic [7:0] VGA_R;
logic [7:0] VGA_G;
logic [7:0] VGA_B;
logic VGA_HS;
logic VGA_VS;
logic VGA_CLK;
logic [7:0] VGA_X;
logic [6:0] VGA_Y;
logic [2:0] VGA_COLOUR;
logic VGA_PLOT;
 logic [32:0] counter;
 logic done_flag;

task3 dut(.CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW), .LEDR(LEDR), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_CLK(VGA_CLK), .VGA_X(VGA_X), .VGA_Y(VGA_Y), .VGA_COLOUR(VGA_COLOUR), .VGA_PLOT(VGA_PLOT));

initial CLOCK_50 = 0;
always #5 CLOCK_50 = ~CLOCK_50;

initial begin
    KEY[3] = 0;
    SW = 0'd0;
    counter = 0;
    done_flag = 0;

    repeat (3) @(posedge CLOCK_50);
    KEY[3] = 1;
    @(posedge CLOCK_50);

    //TEST CASE1
    SW[9:3] = 7'd40;
    SW[2:0] = 3'b010;
    $display("TEST CASE 1: Radius = 40, Colour = Green\n");
    run_task3_test();

    //TEST CASE2
    SW[9:3] = 7'd60;
    SW[2:0] = 3'b011;
    $display("TEST CASE 2: Radius = 60, Colour = 3\n");
    run_task3_test();

    //TEST CASE3
    SW[9:3] = 7'd80;
    SW[2:0] = 3'b111;
    $display("TEST CASE 3: Radius = 80, Colour = White\n");
    run_task3_test();

    $display("All test cases completed.\n");
end

task run_task3_test();
begin
    counter = 0;
    done_flag = 0;
    repeat(20000) begin
        @(posedge CLOCK_50);
        counter = counter + 32'd1;

        if(VGA_PLOT && !done_flag)begin
            $display("Circle done plotting aftr %0d", counter);
            done_flag = 1;
        end
    end

    if(!done_flag)begin
        $display("Timeout reached.\n");
    end

    #30;
end
endtask

always @(posedge CLOCK_50)begin
    if(VGA_PLOT)begin
        $display("Current coordinates of pixel: x = %0d, y = %0d, and colour is %0d", VGA_X, VGA_Y, VGA_COLOUR);
    end
end





endmodule
