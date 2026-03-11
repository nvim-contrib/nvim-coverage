# Changelog

## [1.0.0](https://github.com/nvim-contrib/nvim-coverage/compare/v0.2.1...v1.0.0) (2026-03-11)


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
