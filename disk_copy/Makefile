HEADERS = $(wildcard ../*.inc) $(wildcard ../inc/*.inc) $(wildcard ../lib/*.s) $(wildcard ../mgtk/*.inc) ../toolkits/btk.inc $(wildcard *.inc) $(wildcard res/*.res.??) $(wildcard ../common/res/*.res.??) $(wildcard ../mgtk/fonts/System.*)

include ../res/Makefile.common

TARGETS = $(OUTDIR)/disk_copy.built

.PHONY: clean all
all: $(OUTDIR) $(TARGETS)

$(OUTDIR):
	mkdir -p $(OUTDIR)

clean:
	rm -f $(OUTDIR)/*.o
	rm -f $(OUTDIR)/*.list
	rm -f $(TARGETS)

$(OUTDIR)/disk_copy.o: disk_copy.s $(HEADERS) loader.s auxlc.s main.s ../toolkits/btk.s
	../bin/warnerr ca65 $(CAFLAGS) --listing $(basename $@).list -o $@ $<

# Built segments
$(OUTDIR)/%.built: $(OUTDIR)/%.o ../res/asm.cfg
	../bin/warnerr ld65 $(LDFLAGS) -o '$@' $<
