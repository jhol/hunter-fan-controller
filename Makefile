
outdir=_out/

simulate: $(outdir)packet_generator.vcd
	gtkwave $< >/dev/null 2>/dev/null &

$(outdir)packet_generator.vcd: $(outdir)packet_generator-sim
	cd $(outdir); ./packet_generator-sim

$(outdir)packet_generator-sim: src/packet_generator.v sim/main.v
	mkdir -p $(outdir)
	iverilog -o $@ $^

.PHONY: simulate
