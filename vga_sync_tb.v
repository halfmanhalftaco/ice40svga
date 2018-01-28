`timescale 1 ns / 10 ps
module vga_sync_tb;

  reg clk = 0;
  always #12.5 clk = !clk;


  initial begin
      $dumpfile("vga_sync_tb.vcd");
      $dumpvars(0, vga_sync_tb);
  end
  
  wire hsync, vsync, hblank, vblank;
  vga_sync uut (
    .clk_pixel(clk),
    .hsync(hsync),
    .vsync(vsync),
    .hblank(hblank),
    .vblank(vblank)
    );

    initial begin
      #17_000_000;    // run for a little more than one frame
      $finish;
    end

endmodule
