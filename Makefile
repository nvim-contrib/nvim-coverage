.PHONY: test test-parsers

# Run all parser unit tests via headless Neovim + plenary.nvim
test:
	nvim --headless --noplugin -u tests/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('tests/', { minimal_init = 'tests/minimal_init.lua', sequential = true })" \
		-c "qa!"

# Run only parser specs
test-parsers:
	nvim --headless --noplugin -u tests/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('tests/parsers/', { minimal_init = 'tests/minimal_init.lua', sequential = true })" \
		-c "qa!"
