# Resources Makefile

.PHONY: validate-banner all

all: validate-banner

validate-banner:
	@echo "Validating banner alignment..."
	@gawk '{print length($$0)}' banner.txt