module vga_sync (
  input clk_pixel,		// 40MHz input

  output hsync,
  output vsync,
  
  output reg vblank,
  output reg hblank
);

  // Sync parameters - default 800x600 SVGA
  // These are ordered similar to an X.org modeline
  
  parameter h_pixels        = 800;
  parameter h_sync_start    = h_pixels + 40;             // front porch
  parameter h_sync_end      = h_sync_start + 128;        // sync pulse
  parameter h_line_end      = h_sync_end + 88;           // back porch

  parameter v_lines         = 600;
  parameter v_sync_start    = v_lines + 1;               // front porch
  parameter v_sync_end      = v_sync_start + 4;          // sync pulse
  parameter v_frame_end     = v_sync_end + 23;           // back porch
  
  parameter h_sync_polarity = 1;
  parameter v_sync_polarity = 1;

  // Counters for current line/column
  reg [11:0] line;
  reg [11:0] col;

  wire h_done = (col == h_line_end);
  wire v_done = (line == v_frame_end);

  // increment column counter on each pixel clock
  always @(posedge clk_pixel)
  begin
    if(h_done)
      col <= 0;
    else
      col <= col + 1;
  end

  // increment line counter at end of each line
  always @(posedge h_done)
  begin
    if(v_done)
      line <= 0;
    else
      line <= line + 1;
  end

  // generate sync pulses
  reg vga_HS, vga_VS;
  always @(posedge clk_pixel)
  begin
    vga_HS <= (col >= h_sync_start && col < h_sync_end);
    vga_VS <= (line >= v_sync_start && line < v_sync_end);
    vblank <= line >= v_lines;
    hblank <= col >= h_pixels;
  end

  // SVGA 800x600 sync pulse is positive polarity
  assign hsync = h_sync_polarity ? vga_HS : ~vga_HS;
  assign vsync = v_sync_polarity ? vga_VS : ~vga_VS;

endmodule
