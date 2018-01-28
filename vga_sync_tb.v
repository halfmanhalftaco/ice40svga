module vga_sync_tb;

  reg clk;
  wire hsync, vsync, hblank, vblank;

  vga_sync uut (
    .clk_pixel(clk),
    .hsync(hsync),
    .vsync(vsync),
    .hblank(hblank),
    .vblank(vblank)
    );

    initial clk = 0;

    always
      #5 clk = ~clk;

    initial begin
        $dumpfile("vga_sync_tb.vcd");
        $dumpvars(0, vga_sync_tb);
    end

    initial begin
      repeat (1056*628*60*60) @(posedge clk);
      $finish;
    end

endmodule
