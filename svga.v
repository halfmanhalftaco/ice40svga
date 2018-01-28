module svga(
  input clk,

  output [3:0] LED,
  output [3:0] red,
  output [3:0] green,
  output [3:0] blue,
  output hsync,
  output vsync
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

  wire clk160;
  wire locked;
  assign LED = {3'bzzz, locked};

  // Generate 160MHz
  pll pll (.clock_in(clk), .clock_out(clk160), .locked(locked));

  // div/4 for svga pixel clock 160/4 = 40MHz
  reg [1:0] vga_div;
  wire clk_vga = vga_div[1];
  always @(posedge clk160)
      vga_div <= vga_div + 1;

  // Counters for current line/column
  reg [9:0] line;
  reg [10:0] col;

  wire h_done = (col == h_pixel_end);
  wire v_done = (line == v_lines_end);
  wire in_line = (col >= h_pixel_start);

  // increment column counter on each pixel clock
  always @(posedge clk_vga)
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
  reg in_display;
  always @(posedge clk_vga)
  begin
      vga_HS <= (col >= h_sync_start && col < h_sync_end);
      vga_VS <= (line >= v_sync_start && line < v_sync_end);
      in_display <= line >= v_lines_start && col >= h_pixel_start;
  end

  // SVGA 800x600 sync pulse is positive polarity
  assign hsync = vga_HS;
  assign vsync = vga_VS;

  // generate SMPTE-style color bars

  reg [7:0] bar_count;
  reg [2:0] bar;
  wire bar_edge = (bar_count == 114);
  always @(posedge clk_vga)
  begin
	if(in_line)
    if(bar_count < 114)
		  bar_count <= bar_count + 1;
    else
      begin
        bar <= bar + 1;
        bar_count <= 0;
      end
	else
    begin
      bar <= 0;
		  bar_count <= 0;
    end
  end

  // generate some colors
  always @(posedge clk_vga)
  begin
      if(in_display)
      begin
          case(bar)
		  	0: begin	// white
				red <= 4'b1011;
				green <= 4'b1011;
				blue <= 4'b1011;
			end
			1: begin	//yellow
				red <= 4'b1011;
				green <= 4'b1011;
				blue <= 4'b0000;
			end
			2: begin	//cyan
				red <= 4'b0000;
				green <= 4'b1011;
				blue <= 4'b1011;
			end
			3: begin	//green
				red <= 4'b0000;
				green <= 4'b1011;
				blue <= 4'b0000;
			end
			4: begin	//magenta
				red <= 4'b1011;
				green <= 4'b0000;
				blue <= 4'b1011;
			end
			5: begin	//red
				red <= 4'b1011;
				green <= 4'b0000;
				blue <= 4'b0000;
			end
			6: begin	//blue
				red <= 4'b0000;
				green <= 4'b0000;
				blue <= 4'b1011;
			end
		  endcase
      end
      else
      begin
          red <= 4'b0000;
          green <= 4'b0000;
          blue <= 4'b0000;
      end
  end


endmodule
