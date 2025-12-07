`timescale 1ps/1ps

module tb_syn_circle();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
logic clk;
logic rst_n;
logic [2:0] colour;
logic [7:0] centre_x;
logic [6:0] centre_y;
logic [7:0] radius;
logic start;
logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;
logic [31:0] counter;
logic done_flag;

circle dut(.clk(clk), .rst_n(rst_n), .colour(colour), .centre_x(centre_x), .centre_y(centre_y), .radius(radius), .start(start), .done(done), .vga_x(vga_x), .vga_y(vga_y), .vga_colour(vga_colour), .vga_plot(vga_plot));

initial clk = 0;
always #5 clk = ~clk;

initial begin
    centre_x = 8'd80;
    centre_y = 7'd60;
    radius = 8'd40;
    colour = 3'd010;
    rst_n = 0;
    start = 0;
    counter = 0;
    done_flag = 0;

    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    $display("Circle is being drawn");
    start = 1;

    repeat (200000) begin
        @(posedge clk);
        counter = counter + 32'd1;

        if (done && !done_flag) begin
            $display("Circle completed after %0d cycles", counter);
            done_flag = 1;
        end
    end



   if (!done_flag) begin
    $display("Timeout reached — circle may not have completed.");
   end

    start = 1'b0;
    #30;
end

always @(posedge clk)begin
    if(vga_plot)begin
         $display("Current coordinates of pixel: x = %0d, y = %0d, and colour is %0d", vga_x, vga_y, vga_colour);
    end
end


endmodule: tb_syn_circle
