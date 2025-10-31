`define IDLE 2'b00
`define BEGIN_FILL 2'b10
`define END_FILL 2'b11
`define X_MAX 160
`define Y_MAX 120

module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);

logic [1:0] state;
logic [1:0] next_state;
logic [7:0] x, x_n;
logic [6:0] y, y_n;




always_ff @(posedge clk) begin
    if(!rst_n) begin
        state <= `IDLE;
    end
    else begin
        state <= next_state;
    end
end

always_ff @(posedge clk)begin
     if(!rst_n)begin
          x <= 8'd0;
          y <= 7'd0;
     end
     else begin
          x <= x_n;
          y <= y_n;
     end
end

always_comb begin
     next_state = state;
     x_n = x;
     y_n = y;

     vga_plot = 1'b0;
     done = 1'b0;

     case(state)
          `IDLE: begin
               if(start) begin
                    x_n = 8'd0;
                    y_n = 7'd0;
                    next_state = `BEGIN_FILL;
               end
          end

          `BEGIN_FILL: begin
               vga_plot = 1'b1;
               if(x == 8'd159 && y == 7'd119) begin
                    next_state = `END_FILL;
               end
               else begin
                    if(y == 7'd119)begin
                         y_n = 7'd0;
                         x_n = x + 8'd1;
                    end
                    else begin
                         y_n = y + 7'd1;
                    end
               end
          end

          `END_FILL: begin
               done = 1'd1;
               vga_plot = 1'd0;
               if(!start)begin
                    next_state = `IDLE;
               end
          end

          default: next_state = `IDLE;
     endcase
end

assign vga_x = x;
assign vga_y = y;
assign vga_colour = x[2:0];


     
endmodule