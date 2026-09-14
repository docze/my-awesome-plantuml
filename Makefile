PLANTUML ?= plantuml
SOURCES := $(shell find examples -name '*.puml')
OUT := out

.PHONY: svg png clean

svg:
	@mkdir -p $(OUT)
	$(PLANTUML) -tsvg -o ../../$(OUT) $(SOURCES)

png:
	@mkdir -p $(OUT)
	$(PLANTUML) -tpng -o ../../$(OUT) $(SOURCES)

clean:
	rm -rf $(OUT)
