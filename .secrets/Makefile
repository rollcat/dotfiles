# Usage: make -C ~/.secrets

ALL=pushover.json

.PHONY: all
all: ${ALL}
%: %.age
	age-self-decrypt < $< > $@
