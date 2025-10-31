`define IDLE 2'b00
`define DRAW 2'b01
`define UPDATE 2'b10
`define END_DRAW 2'b11

module circle3(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, 
              input logic [6:0] c_y1,
              input logic [7:0] c_x1, input logic [7:0] c_x2,
              output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);

logic [6:0] offset_y, next_offset_y;
logic [7:0] offset_x, next_offset_x;
logic signed [8:0] crit, next_crit;
logic [2:0] octant, next_octant;
logic [1:0] state;
logic [1:0] next_state;
logic [6:0] pixel_y;
logic [7:0] pixel_x;
logic signed [9:0] temp_x, temp_y;

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
          offset_y <= 7'd0;
          offset_x <= 8'd0;
          crit <= 8'd0;
          octant <= 3'd0;
     end
     else begin
          offset_y <= next_offset_y;
          offset_x <= next_offset_x;
          crit <= next_crit;
          octant <= next_octant;
     end
end


always_comb begin
     next_state = state;
     vga_plot = 1'b0;
     done = 1'b0;
     next_offset_y = offset_y;
     next_offset_x = offset_x;
     next_crit = crit;
     vga_x = 8'd0;
     vga_y = 7'd0;
     vga_colour = 3'd0;
     next_octant = octant;

     temp_x = 10'd0;
     temp_y = 10'd0;

     case(state)
     `IDLE: begin
          if(start) begin
          next_offset_y = 7'd0;
          next_offset_x = radius;
          next_crit = 9'sd1 - radius;
          next_state = `DRAW;
          next_octant = 3'd0;
     end
     end

     `DRAW: begin
          vga_colour = colour;

          case(octant)
          3'd0:  begin temp_x = centre_x + offset_x; temp_y = centre_y + offset_y;end
          3'd1:  begin temp_x = centre_x + offset_y; temp_y = centre_y + offset_x;end
          3'd2:  begin temp_x = centre_x - offset_x; temp_y = centre_y + offset_y;end
          3'd3:  begin temp_x = centre_x - offset_y; temp_y = centre_y + offset_x;end
          3'd4:  begin temp_x = centre_x - offset_x; temp_y = centre_y - offset_y;end
          3'd5:  begin temp_x = centre_x - offset_y; temp_y = centre_y - offset_x;end
          3'd6:  begin temp_x = centre_x + offset_x; temp_y = centre_y - offset_y;end
          3'd7:  begin temp_x = centre_x + offset_y; temp_y = centre_y - offset_x;end

          default: begin vga_x = 8'd0; vga_y = 7'd0; temp_x = 9'd0; temp_y = 9'd0; end
          endcase

          if ((temp_x >= 0) && (temp_x < 160) && (temp_y >= 0) && (temp_y < 120)) begin
               vga_x = temp_x[7:0];
               vga_y = temp_y[6:0];
               vga_plot  = 1'b1;
             end
          else begin
               vga_plot  = 1'b0;
          end
          if((vga_x < 8'd160 || vga_y < 7'd120)&&((vga_y>=c_y1)&&(vga_x>=c_x2)&&(vga_x<=c_x1)))begin
               vga_plot = 1'b1;
          end

          else begin 
               vga_plot = 1'b0;
          end


          if(octant == 3'd7)begin
               next_octant = 3'd0;
               next_state = `UPDATE;
          end
          else begin
               next_octant = octant + 3'd1;
               next_state = `DRAW;
          end
     end

          `UPDATE: begin

               next_offset_y = offset_y + 7'd1;

               if(crit <= 9'sd0)begin
                    next_crit = crit + ((offset_y << 1) + 9'd1);
               end
               else begin
                    next_offset_x = offset_x - 9'd1;
                    next_crit = crit + ((offset_y - offset_x)<<1) + 9'd1;
               end


               if(next_offset_y >= next_offset_x)begin
                    next_state = `END_DRAW;
               end
               else begin
                    next_state = `DRAW;
               end

          end

          `END_DRAW: begin
               done = 1'd1;
               vga_plot = 1'd0;
               if(!start)begin
                    next_state = `IDLE;
               end
          end

          default: next_state = `IDLE;
     endcase

end     
endmodule

