# Banner Alignment Experiment Makefile

.PHONY: all debug test fix clean

BANNER_FILE := ../../resources/banner.txt

all: test

debug:
	@echo "Running banner alignment debugger..."
	@./debug-banner.sh $(BANNER_FILE)

test:
	@echo "Testing banner alignment..."
	@./test-banner.sh $(BANNER_FILE)

fix:
	@echo "Applying banner fix..."
	@./debug-banner.sh $(BANNER_FILE) > debug.log
	@if [ -f "$(BANNER_FILE).fixed" ]; then \
		cp $(BANNER_FILE) $(BANNER_FILE).backup; \
		mv $(BANNER_FILE).fixed $(BANNER_FILE); \
		echo "✅ Banner fixed! Original backed up to $(BANNER_FILE).backup"; \
	else \
		echo "❌ No fixed file generated"; \
	fi

verify:
	@echo "Verifying banner alignment..."
	@awk '{if(length($$0)!=69){print "Line",NR,":",length($$0),"chars";err=1}}END{if(!err)print"✅ All lines are 69 chars"}' $(BANNER_FILE)

clean:
	@echo "Cleaning up..."
	@rm -f *.log *.fixed *.backup

help:
	@echo "Banner Alignment Debugging Tools"
	@echo "==============================="
	@echo "  make debug  - Run detailed debugging analysis"
	@echo "  make test   - Run alignment tests"
	@echo "  make fix    - Apply automatic fixes"
	@echo "  make verify - Quick verification"
	@echo "  make clean  - Remove temporary files"