.PHONY: all

all:
	@ echo "Building escript..."
	@ rebar3 escriptize

install: all
	@ echo "Installing escript..."
	@ cp _build/default/bin/edecompiler /usr/local/bin

.PHONY: clean
clean:
	@rm -rf _build
