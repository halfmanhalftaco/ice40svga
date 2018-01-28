module svga_sync (
  input clk_svga,		// 40MHz input

  output hsync,
  output vsync,
  
  output reg vblank,
  output reg hblank,
);

  // 800x600 SVGA timings
  localparam h_sync_start = 40;                       // front porch
  localparam h_sync_end = h_sync_start + 128;         // sync pulse
  localparam h_pixel_start = h_sync_end + 88;         // back porch
  localparam h_pixel_end = h_pixel_start + 800;       // 800 pixels

  localparam v_sync_start = 1;                        // front porch
  localparam v_sync_end = v_sync_start + 4;           // sync pulse
  localparam v_lines_start = v_sync_end + 23;         // back porch
  localparam v_lines_end = v_lines_start + 600;       // 600 lines

  // Counters for current line/column
  reg [9:0] line;
  reg [10:0] col;

  wire h_done = (col == h_pixel_end);
  wire v_done = (line == v_lines_end);

  // increment column counter on each pixel clock
  always @(posedge clk_svga)
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
  always @(posedge clk_svga)
  begin
    vga_HS <= (col >= h_sync_start && col < h_sync_end);
    vga_VS <= (line >= v_sync_start && line < v_sync_end);
    vblank <= line < v_lines_start;
    hblank <= col < h_pixel_start;
  end

  // SVGA 800x600 sync pulse is positive polarity
  assign hsync = vga_HS;
  assign vsync = vga_VS;

endmodule
