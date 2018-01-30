module colorbars (
  input clk,

  output [3:0] LED,
  output [3:0] red,
  output [3:0] green,
  output [3:0] blue,
  output reg hsync,
  output reg vsync
);

  wire clk160;
  wire locked;
  assign LED = {3'bzzz, locked};

  // Generate 160MHz
  pll160 pll (.clock_in(clk), .clock_out(clk160), .locked(locked));

  // div/4 for svga pixel clock 160/4 = 40MHz
  reg [1:0] svga_div;
  wire clk_svga = svga_div[1];
  always @(posedge clk160)
    svga_div <= svga_div + 1;

  reg hblank, vblank;
  vga_sync vga_sync (.clk_pixel(clk_svga), .hsync(hsync), .vsync(vsync), .hblank(hblank), .vblank(vblank));
  wire in_display = ~(hblank | vblank);

  // generate SMPTE-style color bars

  reg [7:0] bar_count;
  reg [2:0] bar;
  always @(posedge clk_svga)
  begin
  if(in_display)
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
  always @(posedge clk_svga)
  begin
      if(in_display)
        case(bar)
          0: {red, green, blue} <= 12'b1011_1011_1011;  // white
          1: {red, green, blue} <= 12'b1011_1011_0000;  // yellow
          2: {red, green, blue} <= 12'b0000_1011_1011;  // cyan
          3: {red, green, blue} <= 12'b0000_1011_0000;  // green
          4: {red, green, blue} <= 12'b1011_0000_1011;  // magenta
          5: {red, green, blue} <= 12'b1011_0000_0000;  // red
          6: {red, green, blue} <= 12'b0000_0000_1011;  // blue
        endcase
      else
      begin
          {red, green, blue} <= 12'h000;
      end
  end

endmodule
