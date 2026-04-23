# Changelog

## [0.7.3](https://github.com/nvim-contrib/nvim-coverage/compare/v0.7.2...v0.7.3) (2026-04-23)


### Bug Fixes

* **coverage:** place signs on files opened after coverage loads ([8ccdcb0](https://github.com/nvim-contrib/nvim-coverage/commit/8ccdcb08fc055f3bbccac6d26227dad71fcdcfc9))

## [0.7.2](https://github.com/nvim-contrib/nvim-coverage/compare/v0.7.1...v0.7.2) (2026-04-22)


### Bug Fixes

* add postCreateCommand to restore nix volume permissions ([9e29e78](https://github.com/nvim-contrib/nvim-coverage/commit/9e29e784f46c969490bf1d6dba74b23f5ce6badd))
* **coverage/neotest/go:** suppress load notification and keep sign placement ([26c774a](https://github.com/nvim-contrib/nvim-coverage/commit/26c774ab0c2d96c75ea1f4a46cc725ab774b9d96))

## [0.7.1](https://github.com/nvim-contrib/nvim-coverage/compare/v0.7.0...v0.7.1) (2026-03-22)


### Bug Fixes

* **hints:** skip extmarks for out-of-range lines ([df47560](https://github.com/nvim-contrib/nvim-coverage/commit/df47560c7d4068e40dc2fccaadcb9e2f7d9793f5))

## [0.7.0](https://github.com/nvim-contrib/nvim-coverage/compare/v0.6.2...v0.7.0) (2026-03-21)


### Features

* **signs:** add signhl/numhl/linehl config options with runtime toggles ([fbe812f](https://github.com/nvim-contrib/nvim-coverage/commit/fbe812f031e9172384a5c66f6800e4b14ae2692e))

## [0.6.2](https://github.com/nvim-contrib/nvim-coverage/compare/v0.6.1...v0.6.2) (2026-03-14)


### Bug Fixes

* address tech debt and bugs from fork ([f9a45eb](https://github.com/nvim-contrib/nvim-coverage/commit/f9a45eba5bc69d7f9fc102c9cbe800bc6faeba0c))
* **hints:** clear extmarks before placing to prevent duplication on reload ([bfc4bd3](https://github.com/nvim-contrib/nvim-coverage/commit/bfc4bd3ca556a2a3aec7f771b4c9eccc187b7d52))
* **neotest:** use direct listener assignment instead of named keys ([8382fe8](https://github.com/nvim-contrib/nvim-coverage/commit/8382fe84e5dea6122f9cd765334ef91ac9416bcc))
* **tests:** disable swap files in test setup ([2e2e960](https://github.com/nvim-contrib/nvim-coverage/commit/2e2e9603c12c95e1fd83d7b14c4c39a6635a54cf))

## [0.6.1](https://github.com/nvim-contrib/nvim-coverage/compare/v0.6.0...v0.6.1) (2026-03-13)


### Bug Fixes

* add pcall error reporting around coverage.load in Go consumer ([fd8d152](https://github.com/nvim-contrib/nvim-coverage/commit/fd8d152c1eff0e5cf9ba369c79966719f0613a60))
* merge all coverage.out files in neotest Go consumer ([5ce8b35](https://github.com/nvim-contrib/nvim-coverage/commit/5ce8b35cdfb3efb43f4cb93a0b9fb029b3afe933))
* **neotest/go:** add file existence check before coverage conversion ([3f48359](https://github.com/nvim-contrib/nvim-coverage/commit/3f48359ddaa560a6205ebb6e73bfaba272e7a8c4))
* **neotest/go:** find coverage.out from neotest output directories ([b83ee9d](https://github.com/nvim-contrib/nvim-coverage/commit/b83ee9de2ba38ca5e317c470ea8286fae51c07ae))
* **neotest:** suppress notifications in generic consumer ([cabbc3f](https://github.com/nvim-contrib/nvim-coverage/commit/cabbc3fce0e54cbe892111cd145554a0cfa59a16))
* replace broken go tool cover with pure Lua converter in neotest Go consumer ([6eeb669](https://github.com/nvim-contrib/nvim-coverage/commit/6eeb6696649d13c014df9822177ad223a2a55528))
* report close error and genhtml failing with Go module paths ([5e6d302](https://github.com/nvim-contrib/nvim-coverage/commit/5e6d3020ed0942a8dca04bef7926c9599965b8f6))
* simplify Go consumer to convert single coverage.out in cwd ([9fd4bf3](https://github.com/nvim-contrib/nvim-coverage/commit/9fd4bf357fda60600c49cdef6a0efc36d0f503c1))
* wrap neotest listener bodies in vim.schedule for fast-event safety ([fcd79da](https://github.com/nvim-contrib/nvim-coverage/commit/fcd79da6d43b2a4a17768634dc275ea9e6534c2a))

## [0.6.0](https://github.com/nvim-contrib/nvim-coverage/compare/v0.5.0...v0.6.0) (2026-03-12)


### Features

* add CoverageHeatmap text-mode strip treemap ([#27](https://github.com/nvim-contrib/nvim-coverage/issues/27)) ([3fcf1bd](https://github.com/nvim-contrib/nvim-coverage/commit/3fcf1bdbcdb96d3fbdf66e7aef92219b584d6c66))
* add CoverageLoad! bang for interactive lcov file picker ([#23](https://github.com/nvim-contrib/nvim-coverage/issues/23)) ([1c6e05d](https://github.com/nvim-contrib/nvim-coverage/commit/1c6e05d9ddfb5e2a79c09440b03fe785487b745d))
* add CoverageOpenHtml to open genhtml report in browser ([#25](https://github.com/nvim-contrib/nvim-coverage/issues/25)) ([c741b24](https://github.com/nvim-contrib/nvim-coverage/commit/c741b24aeb9a6585d07d5743871d142089c55719))
* ship built-in neotest consumer for Python coverage ([0259bb3](https://github.com/nvim-contrib/nvim-coverage/commit/0259bb31cf0b52e88c082fd9bde265028071013b))


### Bug Fixes

* add 1-char gap between heatmap blocks via highlight inset ([e3ca3e3](https://github.com/nvim-contrib/nvim-coverage/commit/e3ca3e3dc494bb085ed71c504fe565f609d2a387))
* add rounded border and centered title to heatmap float ([b9b23d6](https://github.com/nvim-contrib/nvim-coverage/commit/b9b23d6eb6102e92b9f82796808e1d967e95bd74))
* clean up heatmap module bugs ([5e6e7d0](https://github.com/nvim-contrib/nvim-coverage/commit/5e6e7d097d5d2adda71d92313c7d457f49470d62))
* make report popup opaque and center table content ([8687813](https://github.com/nvim-contrib/nvim-coverage/commit/868781309266f8d4fb7a550add2b0b92986006b4))
* move get_padding_width after get_filename_width (Lua scoping) ([2b48f51](https://github.com/nvim-contrib/nvim-coverage/commit/2b48f51d2779c28bbd60b8083fa3b32739508124))
* move pick_and_load above M.setup so it is in scope when called ([cdb9f73](https://github.com/nvim-contrib/nvim-coverage/commit/cdb9f73c270efc50ef048acd21625658f15d3642))
* remove heatmap border for cleaner full-screen UI ([8ac1705](https://github.com/nvim-contrib/nvim-coverage/commit/8ac1705c52730a69ecd6e9ca9ade37aba2ae7262))
* remove stray blank line in M.load ([e63c945](https://github.com/nvim-contrib/nvim-coverage/commit/e63c945986ecb795d953f5db3f0858733e820715))
* **spec:** update module paths after coverage.report → cache rename ([8e6b703](https://github.com/nvim-contrib/nvim-coverage/commit/8e6b7030898eb1aeea55689023a6b2cb4295589c))
* **tests:** update fixture paths from spec/ to tests/ ([01851f0](https://github.com/nvim-contrib/nvim-coverage/commit/01851f05871fd0216d5c77f5f16b21548b8fed99))
* use relative paths and correct title in coverage report ([f7bd69d](https://github.com/nvim-contrib/nvim-coverage/commit/f7bd69d25b9611c14e9330b80612b7725e2b6e06))

## [0.5.0](https://github.com/nvim-contrib/nvim-coverage/compare/v0.4.0...v0.5.0) (2026-03-11)


### ⚠ BREAKING CHANGES

* breaking API renames for ergonomics
* the `lcov_file` configuration key is renamed to `file`.

### Features

* add CoverageQuickfix and CoverageLoclist commands (close [#16](https://github.com/nvim-contrib/nvim-coverage/issues/16)) ([8713945](https://github.com/nvim-contrib/nvim-coverage/commit/8713945519365a9b0bc7de2847755415ac113a1c))
* add Dart config ([065fede](https://github.com/nvim-contrib/nvim-coverage/commit/065fede12826e35fdee128b130c43bcb619fe73d))
* Add java jacoco coverage support ([a939e42](https://github.com/nvim-contrib/nvim-coverage/commit/a939e425e363319d952a6c35fb3f38b34041ded2))
* added typescriptreact filetype (same as typescript/jacascript) ([d73dd63](https://github.com/nvim-contrib/nvim-coverage/commit/d73dd633b2c62e3e4e7cfb1e4c268ab2a9a7b55a))
* added typescriptreact filetype (same as typescript/jacascript) ([fdd6752](https://github.com/nvim-contrib/nvim-coverage/commit/fdd67521bf745f7a6682cbb095020dab8faa0709))
* branch overlay popup ([#15](https://github.com/nvim-contrib/nvim-coverage/issues/15)) ([1ca59e0](https://github.com/nvim-contrib/nvim-coverage/commit/1ca59e0cde8b3e619dc7ff64d8dd3604c13ca5e7))
* breaking API renames for ergonomics ([1e461d4](https://github.com/nvim-contrib/nvim-coverage/commit/1e461d44fa9c53d8fa7feb38aa7bff986af7168d))
* default file to common lcov paths list ([abfa535](https://github.com/nvim-contrib/nvim-coverage/commit/abfa5354fb77fe43d011c77c1df34d68dcb51047))
* path compatibility ([492c1a8](https://github.com/nvim-contrib/nvim-coverage/commit/492c1a835cf79fcb808b22bb5fb863b2d4e08cbf))
* quickfix and loclist navigation (close [#16](https://github.com/nvim-contrib/nvim-coverage/issues/16)) ([d85e3b6](https://github.com/nvim-contrib/nvim-coverage/commit/d85e3b6bccbaffabd92ae73d237eb68c09fa165a))
* read the entire jacoco report ([906fad0](https://github.com/nvim-contrib/nvim-coverage/commit/906fad0363b80f0d83897890f6219ef0189756ad))
* rename lcov_file config option to file ([7dfa05c](https://github.com/nvim-contrib/nvim-coverage/commit/7dfa05c5d183f62cc36fb674f07c44e3814cdabe))
* ship built-in neotest consumers for generic and Go coverage ([dd4e8d0](https://github.com/nvim-contrib/nvim-coverage/commit/dd4e8d08e29cee4099a729a3f4a4152b9b0c6f36))
* **summary:** allow custom win options for summary window ([da956c2](https://github.com/nvim-contrib/nvim-coverage/commit/da956c2853e6e83b56bbfde5c5517f16643ce323))
* support list of lcov file paths (closes [#7](https://github.com/nvim-contrib/nvim-coverage/issues/7)) ([f4d6d54](https://github.com/nvim-contrib/nvim-coverage/commit/f4d6d54d17679cf114d9a1030c9a13fd770c185d))
* support nested go modules (monorepo) ([e582e52](https://github.com/nvim-contrib/nvim-coverage/commit/e582e520e9f6458389f1f1478dadc264f8c27e08))
* support nested go modules (monorepo) ([0026441](https://github.com/nvim-contrib/nvim-coverage/commit/0026441f716e642c7bbc9161381c6eed5bc54af3))
* takes total of missed and covered branches and lines ([ddee593](https://github.com/nvim-contrib/nvim-coverage/commit/ddee593da2d4db420943ff3c7a1d20b1b8331701))
* virtual text hit counts ([#13](https://github.com/nvim-contrib/nvim-coverage/issues/13)) ([e559e80](https://github.com/nvim-contrib/nvim-coverage/commit/e559e8096387aacc2684fa32573ea020dd10724a))


### Bug Fixes

* broken auto_reload when using list or function for coverage file ([668549b](https://github.com/nvim-contrib/nvim-coverage/commit/668549b9f28ae20b521e2352978fbae235b36775))
* only set the highlight groups as default ([42eb08e](https://github.com/nvim-contrib/nvim-coverage/commit/42eb08eec941b34b17a86ad65f7dd69061484c35))
* python - actually use the coverage-file ([aa4b440](https://github.com/nvim-contrib/nvim-coverage/commit/aa4b4400588e2259e87e372b1e4e90ae13cf5a39))
* python - actually use the coverage-file ([1b0dafb](https://github.com/nvim-contrib/nvim-coverage/commit/1b0dafb737a81ffb9547d39f9bffb53b750d7b15))
* robust path matching in overlay using bufnr fallback ([4826987](https://github.com/nvim-contrib/nvim-coverage/commit/4826987036170611e0f07162303b8073268f91c0))
* **rust:** replace grcov/coveralls with lcov file-based coverage ([1bec71e](https://github.com/nvim-contrib/nvim-coverage/commit/1bec71e10d42032493537c4f60dc543196fb6bf7))
* stable baseline before breaking API changes ([0505063](https://github.com/nvim-contrib/nvim-coverage/commit/0505063e6cc7afce91c6a9372159cd4e4f59035a))

## [0.4.0](https://github.com/nvim-contrib/nvim-coverage/compare/v0.3.0...v0.4.0) (2026-03-11)


### Features

* branch overlay popup ([#15](https://github.com/nvim-contrib/nvim-coverage/issues/15)) ([1ca59e0](https://github.com/nvim-contrib/nvim-coverage/commit/1ca59e0cde8b3e619dc7ff64d8dd3604c13ca5e7))


### Bug Fixes

* robust path matching in overlay using bufnr fallback ([4826987](https://github.com/nvim-contrib/nvim-coverage/commit/4826987036170611e0f07162303b8073268f91c0))

## [0.3.0](https://github.com/nvim-contrib/nvim-coverage/compare/v0.2.1...v0.3.0) (2026-03-11)


### ⚠ BREAKING CHANGES

* breaking API renames for ergonomics
* the `lcov_file` configuration key is renamed to `file`.

### Features

* breaking API renames for ergonomics ([1e461d4](https://github.com/nvim-contrib/nvim-coverage/commit/1e461d44fa9c53d8fa7feb38aa7bff986af7168d))
* default file to common lcov paths list ([abfa535](https://github.com/nvim-contrib/nvim-coverage/commit/abfa5354fb77fe43d011c77c1df34d68dcb51047))
* rename lcov_file config option to file ([7dfa05c](https://github.com/nvim-contrib/nvim-coverage/commit/7dfa05c5d183f62cc36fb674f07c44e3814cdabe))
* support list of lcov file paths (closes [#7](https://github.com/nvim-contrib/nvim-coverage/issues/7)) ([f4d6d54](https://github.com/nvim-contrib/nvim-coverage/commit/f4d6d54d17679cf114d9a1030c9a13fd770c185d))
* virtual text hit counts ([#13](https://github.com/nvim-contrib/nvim-coverage/issues/13)) ([e559e80](https://github.com/nvim-contrib/nvim-coverage/commit/e559e8096387aacc2684fa32573ea020dd10724a))

## [0.2.1](https://github.com/nvim-contrib/nvim-coverage/compare/v0.2.0...v0.2.1) (2026-03-11)


### Bug Fixes

* stable baseline before breaking API changes ([0505063](https://github.com/nvim-contrib/nvim-coverage/commit/0505063e6cc7afce91c6a9372159cd4e4f59035a))

## [0.2.0](https://github.com/nvim-contrib/nvim-coverage/compare/v0.1.0...v0.2.0) (2026-03-11)


### Features

* add Dart config ([065fede](https://github.com/nvim-contrib/nvim-coverage/commit/065fede12826e35fdee128b130c43bcb619fe73d))
* Add java jacoco coverage support ([a939e42](https://github.com/nvim-contrib/nvim-coverage/commit/a939e425e363319d952a6c35fb3f38b34041ded2))
* added typescriptreact filetype (same as typescript/jacascript) ([d73dd63](https://github.com/nvim-contrib/nvim-coverage/commit/d73dd633b2c62e3e4e7cfb1e4c268ab2a9a7b55a))
* added typescriptreact filetype (same as typescript/jacascript) ([fdd6752](https://github.com/nvim-contrib/nvim-coverage/commit/fdd67521bf745f7a6682cbb095020dab8faa0709))
* path compatibility ([492c1a8](https://github.com/nvim-contrib/nvim-coverage/commit/492c1a835cf79fcb808b22bb5fb863b2d4e08cbf))
* read the entire jacoco report ([906fad0](https://github.com/nvim-contrib/nvim-coverage/commit/906fad0363b80f0d83897890f6219ef0189756ad))
* **summary:** allow custom win options for summary window ([da956c2](https://github.com/nvim-contrib/nvim-coverage/commit/da956c2853e6e83b56bbfde5c5517f16643ce323))
* support nested go modules (monorepo) ([e582e52](https://github.com/nvim-contrib/nvim-coverage/commit/e582e520e9f6458389f1f1478dadc264f8c27e08))
* support nested go modules (monorepo) ([0026441](https://github.com/nvim-contrib/nvim-coverage/commit/0026441f716e642c7bbc9161381c6eed5bc54af3))
* takes total of missed and covered branches and lines ([ddee593](https://github.com/nvim-contrib/nvim-coverage/commit/ddee593da2d4db420943ff3c7a1d20b1b8331701))


### Bug Fixes

* broken auto_reload when using list or function for coverage file ([668549b](https://github.com/nvim-contrib/nvim-coverage/commit/668549b9f28ae20b521e2352978fbae235b36775))
* only set the highlight groups as default ([42eb08e](https://github.com/nvim-contrib/nvim-coverage/commit/42eb08eec941b34b17a86ad65f7dd69061484c35))
* python - actually use the coverage-file ([aa4b440](https://github.com/nvim-contrib/nvim-coverage/commit/aa4b4400588e2259e87e372b1e4e90ae13cf5a39))
* python - actually use the coverage-file ([1b0dafb](https://github.com/nvim-contrib/nvim-coverage/commit/1b0dafb737a81ffb9547d39f9bffb53b750d7b15))
* **rust:** replace grcov/coveralls with lcov file-based coverage ([1bec71e](https://github.com/nvim-contrib/nvim-coverage/commit/1bec71e10d42032493537c4f60dc543196fb6bf7))
