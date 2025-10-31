`timescale 1ns/1ps

module tb_syn_task2();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
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

task2 dut (.CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW), .LEDR(LEDR), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_CLK(VGA_CLK), .VGA_X(VGA_X), .VGA_Y(VGA_Y), .VGA_COLOUR(VGA_COLOUR), .VGA_PLOT(VGA_PLOT));

initial CLOCK_50 = 0;
always #5 CLOCK_50 = ~CLOCK_50;

initial begin
    KEY = 4'b0000;
    SW  = 10'b0000000000;
    counter = 0;
    done_flag = 0;

    #50;
    KEY[3] = 1;
    #20;

    repeat (200000) begin
        @(posedge CLOCK_50);
        counter = counter + 32'd1;

        if (VGA_PLOT && VGA_X == 8'd159 && VGA_Y == 7'd119) begin
            $display("Reached the end of the screen after %0d cycles.", counter);
            done_flag = 1;
            break; // exit the loop
        end
    end

    if (!done_flag)
        $display("Timeout reached — plotting may be incomplete.");
end



endmodule: tb_syn_task2
