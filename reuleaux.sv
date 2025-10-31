`define IDLE 2'b00
`define CIRCLE1 2'b01
`define CIRCLE2 2'b10
`define CIRCLE3 2'b11

`define sqrt3div6 10'd288
`define sqrt3div3 10'd577

module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     
logic signed [7:0] c_x, c_x1, c_x2, c_x3;
logic signed [6:0] c_y, c_y1, c_y2, c_y3;

// Outputs from CIRCLE1
logic [7:0] c1_vga_x;
logic [6:0] c1_vga_y;
logic c1_vga_plot;

// Outputs from CIRCLE2
logic [7:0] c2_vga_x;
logic [6:0] c2_vga_y;
logic c2_vga_plot;

// Outputs from  CIRCLE3
logic [7:0] c3_vga_x;
logic [6:0] c3_vga_y;
logic c3_vga_plot;

/// Temps 

logic [15:0] temp_y1;
logic [15:0] temp_y2;
logic [15:0] temp_y3; 





// Colours
logic[2:0] c1_vga_colour, c2_vga_colour, c3_vga_colour;



assign c_y1 = temp_y1[6:0];
assign c_y2 = temp_y2[6:0];
assign c_y3 = temp_y3[6:0];


always_comb begin
c_x = centre_x;
c_y = centre_y;
c_x1 = c_x + (diameter>>1);
temp_y1 = c_y + ((diameter * `sqrt3div6)/ 10'd1000);

c_x2 = c_x - (diameter>>1);
temp_y2 = c_y + ((diameter * `sqrt3div6)/ 10'd1000); 

c_x3 = c_x;

temp_y3 = c_y - ((diameter * `sqrt3div3)/ 10'd1000); 

end

logic [1:0] state, next_state;
logic start1, start2, start3;
logic done1, done2, done3;

always_ff @(posedge clk) begin
    if(!rst_n) begin
        state <= `IDLE;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin
     next_state = state;
     start1 = 1'b0;
     start2 = 1'b0;
     start3 = 1'b0;
     done = 1'b0;
case(state)
     `IDLE: begin
          if(start)begin
               next_state = `CIRCLE1; 
          end
     end

     `CIRCLE1: begin 
          start1 = 1'b1;
          if(done1)begin
               next_state = `CIRCLE2;
               end
          
               
          end
     
     `CIRCLE2: begin
          start2 = 1'b1;
          if(done2)begin
               next_state = `CIRCLE3;
          end
     end

     `CIRCLE3: begin
          start3 = 1'b1;
          if(done3) begin
               done = 1'b1;
               if(!start) begin
               next_state = `IDLE;
               end
          end     
     end
     default: next_state = `IDLE; 

endcase
end

assign vga_x = (state == `CIRCLE1)? c1_vga_x: (state == `CIRCLE2)? c2_vga_x: c3_vga_x;
assign vga_y = (state == `CIRCLE1)? c1_vga_y: (state == `CIRCLE2)? c2_vga_y: c3_vga_y;
assign vga_plot = (state == `CIRCLE1)? c1_vga_plot: (state == `CIRCLE2)? c2_vga_plot: c3_vga_plot;

assign vga_colour = (state == `CIRCLE1) ? c1_vga_colour :(state == `CIRCLE2) ? c2_vga_colour : c3_vga_colour;

circle1 cir1(
        .clk(clk), 
        .rst_n(rst_n), 
        .colour(colour),
        .centre_x(c_x1),
        .centre_y(c_y1), 
        .radius(diameter),
        .start(start1),
        .c_x2(c_x2),
        .c_x3(c_x3),
        .done(done1),
        .vga_x(c1_vga_x),
        .vga_y(c1_vga_y),
        .vga_colour(c1_vga_colour),
        .vga_plot(c1_vga_plot));

circle2 cir2(
        .clk(clk), 
        .rst_n(rst_n), 
        .colour(colour),
        .centre_x(c_x2),
        .centre_y(c_y2), 
        .radius(diameter),
        .start(start2),
        .c_x1(c_x1),
        .c_x3(c_x3),
        .done(done2),
        .vga_x(c2_vga_x),
        .vga_y(c2_vga_y),
        .vga_colour(c2_vga_colour),
        .vga_plot(c2_vga_plot));

circle3 cir3(
        .clk(clk), 
        .rst_n(rst_n), 
        .colour(colour),
        .centre_x(c_x3),
        .centre_y(c_y3), 
        .radius(diameter),
        .start(start3),
        .c_y1(c_y1),
        .c_x1(c_x1),
        .c_x2(c_x2),
        .done(done3),
        .vga_x(c3_vga_x),
        .vga_y(c3_vga_y),
        .vga_colour(c3_vga_colour),
        .vga_plot(c3_vga_plot));



endmodule

