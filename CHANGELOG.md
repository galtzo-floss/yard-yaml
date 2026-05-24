# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

- `documentation_local.gemfile` support for sibling-workspace documentation development under `KETTLE_RB_DEV`
- Added generated CI coverage for `rdoc` `~> 6.11` and `>= 7.0`.

### Changed

- Refreshed generated project tooling, CI, and documentation support from the current `kettle-jem` template.

### Deprecated

### Removed

### Fixed

- `Yard::Yaml::Converter.from_file` now preserves valid UTF-8 text, scrubs malformed UTF-8 safely in non-strict mode, and rejects binary-ish inputs without raw encoding crashes

### Security

## [0.1.0] - 2025-11-10

- TAG: [v0.1.0][0.1.0t]
- COVERAGE: 91.13% -- 421/462 lines in 12 files
- BRANCH COVERAGE: 75.47% -- 120/159 branches in 12 files
- 84.38% documented

### Added

- Initial release

### Security

[Unreleased]: https://github.com/galtzo-floss/yard-yaml/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/galtzo-floss/yard-yaml/compare/ffbe883471d11462dc28675867d852372ea3a481...v0.1.0
[0.1.0t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.1.0
