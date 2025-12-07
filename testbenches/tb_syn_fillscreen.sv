`timescale 1ps/1ps

module tb_syn_fillscreen();

logic clk;
logic rst_n;
logic [2:0] colour;
logic start;
logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

fillscreen dut (.clk(clk), .rst_n(rst_n), .colour(colour), .start(start), .done(done), .vga_x(vga_x), .vga_y(vga_y), .vga_colour(vga_colour), .vga_plot(vga_plot));

initial clk = 0;
always #5 clk = ~clk;

initial begin
    rst_n = 0; start = 0; colour = 3'b101;
    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
    start = 1;

    wait(done);
    $display("Filling the screen is complete");

    start = 1'b0;
    #30;
    $finish;
end

always @(posedge clk)begin
    if(vga_plot)
    $display("Current coordinates of pixel: x = %0d, y = %0d, and colour is %0d", vga_x, vga_y, vga_colour);
end

initial begin
    wait(done)
    if(vga_x == 8'd159 && vga_y == 7'd119)begin
        $display("Reached the end of the screen");
    end
    else begin
        $display("Did not fill the screen successfully");
    end
end


endmodule: tb_syn_fillscreen
