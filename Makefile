TOP = colorbars
SRC = colorbars.v vga_sync.v pll.v

all: ${TOP}.bin
	
clean:
	rm -f ${TOP}.{asc,bin,blif} *.vcd *_tb
	
sim: vga_sync_tb.vcd

time: ${TOP}.asc ${TOP}.pcf
	icetime -d hx8k -p ${TOP}.pcf -P tq144 -t ${TOP}.asc

${TOP}.bin: ${TOP}.asc
	icepack ${TOP}.asc $@ 

${TOP}.asc: ${TOP}.blif ${TOP}.pcf
	arachne-pnr -d 8k -P tq144:4k -o $@ -p ${TOP}.pcf ${TOP}.blif

${TOP}.blif: ${SRC}
	yosys -q -p 'synth_ice40 -top ${TOP} -blif $@' ${SRC}

%_tb: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb
	vvp -N $<
