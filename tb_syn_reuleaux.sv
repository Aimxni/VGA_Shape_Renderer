module tb_syn_reuleaux();


// INPUT AND OUTPUTS
logic clk;
logic rst_n;

logic [2:0] colour;
logic [7:0] centre_x;
logic [6:0] centre_y;
logic [7:0] diameter;
logic start;

logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

logic [31:0] counter;
logic done_flag;

//INSTANTIATE DUT
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

//CLOCK GENERATION
initial clk = 0;
always #5 clk = ~clk;

//TEST SEQUENCE
initial begin
    // INITIAL VALUES
    rst_n = 0;
    start = 0;
    counter = 0;
    done_flag = 0;
    colour = 3'b010;

    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // TEST CASE 1
    centre_x = 8'd80;
    centre_y = 7'd60;
    diameter = 8'd40;
    $display("TEST CASE 1: Center=(80,60), Diameter=40\n");
    run_reuleaux_test();

    // TEST CASE 2
    centre_x = 8'd100;
    centre_y = 7'd70;
    diameter = 8'd30;
    $display("TEST CASE 2: Center=(100,70), Diameter\n");
    run_reuleaux_test();

    // TEST CASE 3
    centre_x = 8'd50;
    centre_y = 7'd50;
    diameter = 8'd50;
    $display("TEST CASE 3: Center=(50,50), Diameter=50\n");
    run_reuleaux_test();

    $display("All test cases completed.\n");
    $finish;
end

// TESTING DIFFERENT CASES
task run_reuleaux_test();
begin
    start = 1'b1;
    counter = 0;
    done_flag = 0;

    repeat (200000) begin
        @(posedge clk);
        counter = counter + 32'd1;

        if (done && !done_flag) begin
            $display("Reuleaux completed after %0d cycles", counter);
            done_flag = 1;
        end
    end

    if (!done_flag) begin
        $display("Timeout reached — Reuleaux may not have completed.");
    end

    start = 1'b0;
    #30;
end
endtask

//PRINT EVERY PLOTTED PIXEL
always @(posedge clk) begin
    if (vga_plot) begin
        $display("Current coordinates of pixel: x = %0d, y = %0d, and colour is %0d", vga_x, vga_y, vga_colour);
    end
end

endmodule: tb_syn_reuleaux
