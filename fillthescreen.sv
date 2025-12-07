module fillthescreen(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module
logic rst_n;
assign rst_n = KEY[3];
logic [7:0] vga_x;
logic [6:0] vga_y;
logic vga_plot;
logic done;
logic start;

always_ff @(posedge CLOCK_50)begin
    if(!rst_n)begin
        start <= 1'b0;
    end
    else begin
        start <= 1'b1;
    end
end

 fillscreen fill_inst(
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .colour(SW[2:0]),
        .start(start),
        .done(done),
        .vga_x(VGA_X),
        .vga_y(VGA_Y),
        .vga_colour(VGA_COLOUR),
        .vga_plot(VGA_PLOT)
    );

 vga_adapter VGA(
        .resetn(rst_n),
        .clock(CLOCK_50),
        .colour(VGA_COLOUR),
        .x(VGA_X),
        .y(VGA_Y),
        .plot(VGA_PLOT),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_CLK(VGA_CLK)
    );

 
endmodule: task2
