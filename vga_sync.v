module vga_sync (
  input clk_pixel,
  input reset,

  output hsync,
  output vsync,
  
  output hblank,
  output vblank
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
  
  parameter hsync_polarity = 1;
  parameter vsync_polarity = 1;

  // Counters for current line/column
  reg [10:0] col;
  reg [10:0] line;
  
  initial begin
    col = 0;
    line = 0;
  end

  wire h_done = (col == h_line_end - 1);
  wire v_done = (line == v_frame_end - 1);
  
  reg hsync_reg, vsync_reg;
  reg hblank_reg, vblank_reg;
  
  // increment counters
  always @(posedge clk_pixel)
  begin
    if (reset)
      begin
        col <= 0;
        line <= 0;
        hsync_reg <= 0;
        vsync_reg <= 0;
      end
    else
      begin
        hsync_reg <= (col >= h_sync_start-1 && col < h_sync_end-1);
        vsync_reg <= (line >= v_sync_start && line < v_sync_end);
        hblank_reg <= col >= h_pixels-1 && col < h_line_end - 1;
        vblank_reg <= line >= v_lines && line < v_frame_end;
        
        if(h_done)
          begin
            col <= 0;
            if(v_done)
              line <= 0;
            else
              line <= line + 1;
          end
        else
          col <= col + 1;
      end
  end

  assign hsync = hsync_polarity ? hsync_reg : ~hsync_reg;
  assign vsync = vsync_polarity ? vsync_reg : ~vsync_reg;
  assign hblank = hblank_reg;
  assign vblank = vblank_reg;

endmodule
