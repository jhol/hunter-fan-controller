
outdir=_out/
src=src/packet_generator.v src/uart.v

synthesize: $(outdir)hunter.bin

$(outdir)hunter.bin: syn/top.v syn/hunter.pcf $(src)
	yosys -q -p "synth_ice40 -blif $(outdir)hunter.blif" syn/top.v $(src)
	arachne-pnr -d 8k -p syn/hunter.pcf $(outdir)hunter.blif -o $(outdir)hunter.txt
	icebox_explain $(outdir)hunter.txt > $(outdir)hunter.ex
	icepack $(outdir)hunter.txt $(outdir)hunter.bin

simulate: $(outdir)packet_generator.vcd
	gtkwave $< >/dev/null 2>/dev/null &

$(outdir)packet_generator.vcd: $(outdir)packet_generator-sim
	cd $(outdir); ./packet_generator-sim

$(outdir)packet_generator-sim: src/packet_generator.v sim/main.v
	mkdir -p $(outdir)
	iverilog -o $@ $^

.PHONY: synthesize simulate
