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

- Documentation linting now has its generated `yard-lint` dependency and severity config available in the local bundle.

- kettle-jem-template-20260726-001 - Projects now include YARD lint
  configuration and documentation dependencies so documentation issues fail
  before generated docs are refreshed.

### Changed

- kettle-jem-template-20260716-001 - Shim gemspec manifests now include
  `LICENSE.md` instead of nonexistent `LICENSE.txt`.
- kettle-jem-template-20260716-002 - Generated gemspec manifests now ship fewer
  repository-only files by default to reduce downstream distro packaging churn.
- kettle-jem-template-20260720-001 - Generated READMEs can now render
  template-managed corporate sponsor logos from project or family config.
- kettle-jem-template-20260720-002 - Generated development Gemfiles now use the
  released `tree_sitter_language_pack` gem 1.13.3 or newer by default.
- kettle-jem-template-20260720-003 - Generated StructuredMerge Git diff driver
  config now uses the installed `smorg-rb` Ruby driver name.
- kettle-jem-template-20260720-004 - Generated multi-engine workflow files now
  omit JRuby and TruffleRuby jobs when project config declares MRI-only engines.
- kettle-jem-template-20260720-005 - Generated README Support & Community rows
  now include a RubyForum help badge.
- kettle-jem-template-20260725-001 - Generated JRuby and TruffleRuby workflow
  files now run when pull request head branches start with `feature/release`,
  so release CI monitoring does not report intentionally skipped engine
  workflows as failures.

- kettle-jem-template-20260725-002 - Generated gemspec templates now include
  `anonymous_loader` as a development dependency, and version specs use it to
  execute generated `version.rb` files for coverage without redefining package
  constants. Managed version specs are removed when `version_gem` is disabled
  or incompatible with the project's runtime Ruby floor.

### Deprecated

### Removed

### Fixed

- kettle-jem-template-20260726-002 - Generated version files now document their
  version namespace and constants, reducing warning-only YARD lint output.

### Security

## [0.2.3] - 2026-07-02

- TAG: [v0.2.3][0.2.3t]
- COVERAGE: 94.36% -- 519/550 lines in 13 files
- BRANCH COVERAGE: 83.25% -- 164/197 branches in 13 files
- 78.38% documented

### Fixed

- Package configured license files in gem release file lists.

## [0.2.2] - 2026-06-22

- TAG: [v0.2.2][0.2.2t]
- COVERAGE: 94.36% -- 519/550 lines in 13 files
- BRANCH COVERAGE: 83.25% -- 164/197 branches in 13 files
- 78.38% documented

### Added

- Added support for JRuby 10.1 and TruffleRuby 34.0.

### Changed

- Retemplated project metadata and CI/development automation with `kettle-jem` v7.0.0.

### Fixed

- Corrected RubyGems homepage metadata to point at the gem documentation site.

## [0.2.1] - 2026-06-14

- TAG: [v0.2.1][0.2.1t]
- COVERAGE: 94.88% -- 519/547 lines in 12 files
- BRANCH COVERAGE: 83.25% -- 164/197 branches in 12 files
- 78.38% documented

### Fixed

- Restored `docs/CNAME` so the generated documentation site keeps its custom domain.

## [0.2.0] - 2026-06-03

- TAG: [v0.2.0][0.2.0t]
- COVERAGE: 94.88% -- 519/547 lines in 12 files
- BRANCH COVERAGE: 83.25% -- 164/197 branches in 12 files
- 78.38% documented

### Changed

- upgrade yaml-converter to v0.2.0
- upgrade version_gem to v1.1.10

## [0.1.3] - 2026-05-27

- TAG: [v0.1.3][0.1.3t]
- COVERAGE: 94.88% -- 519/547 lines in 12 files
- BRANCH COVERAGE: 83.25% -- 164/197 branches in 12 files
- 78.38% documented

### Fixed

- YAML documentation pages no longer truncate long source lines by default,
  preserving full values such as repository URLs in rendered CFF pages.

## [0.1.2] - 2026-05-27

- TAG: [v0.1.2][0.1.2t]
- COVERAGE: 94.88% -- 519/547 lines in 12 files
- BRANCH COVERAGE: 83.25% -- 164/197 branches in 12 files
- 78.38% documented

### Changed

- Documented that `yard-yaml` discovers YAML/CFF files through its own globs
  and that listing those files as plain YARD inputs is only needed when users
  intentionally want YARD's raw file-page rendering too.

### Fixed

- Converted YAML page filenames now default to source paths instead of YAML
  titles, keeping display titles separate from stable output paths and avoiding
  silent overwrites when titles collide.
- Expanded plugin, logger, registry, and tag-renderer specs so the test suite
  again satisfies the configured line and branch coverage gates.
- `--plugin yaml` now activates discovery and emits converted YAML pages after
  YARD finishes generating HTML.
- `Yard::Yaml::Converter` now adapts to `yaml-converter`'s real in-memory
  Markdown API instead of calling an obsolete positional `convert` signature.

## [0.1.1] - 2026-05-24

- TAG: [v0.1.1][0.1.1t]
- COVERAGE: 92.61% -- 451/487 lines in 12 files
- BRANCH COVERAGE: 76.88% -- 133/173 branches in 12 files
- 77.46% documented

### Added

- `documentation_local.gemfile` support for sibling-workspace documentation development under `KETTLE_DEV_DEV`
- Added generated CI coverage for `rdoc` `~> 6.11` and `>= 7.0`.

### Changed

- Refreshed generated project tooling, CI, and documentation support from the current `kettle-jem` template.

### Fixed

- `Yard::Yaml::Converter.from_file` now preserves valid UTF-8 text, scrubs malformed UTF-8 safely in non-strict mode, and rejects binary-ish inputs without raw encoding crashes

## [0.1.0] - 2025-11-10

- TAG: [v0.1.0][0.1.0t]
- COVERAGE: 91.13% -- 421/462 lines in 12 files
- BRANCH COVERAGE: 75.47% -- 120/159 branches in 12 files
- 84.38% documented

### Added

- Initial release

### Security

[Unreleased]: https://github.com/galtzo-floss/yard-yaml/compare/v0.2.3...HEAD
[0.2.3]: https://github.com/galtzo-floss/yard-yaml/compare/v0.2.2...v0.2.3
[0.2.3t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.2.3
[0.2.2]: https://github.com/galtzo-floss/yard-yaml/compare/v0.2.1...v0.2.2
[0.2.2t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.2.2
[0.2.1]: https://github.com/galtzo-floss/yard-yaml/compare/v0.2.0...v0.2.1
[0.2.1t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.2.1
[0.2.0]: https://github.com/galtzo-floss/yard-yaml/compare/v0.1.3...v0.2.0
[0.2.0t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.2.0
[0.1.3]: https://github.com/galtzo-floss/yard-yaml/compare/v0.1.2...v0.1.3
[0.1.3t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.1.3
[0.1.2]: https://github.com/galtzo-floss/yard-yaml/compare/v0.1.1...v0.1.2
[0.1.2t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.1.2
[0.1.1]: https://github.com/galtzo-floss/yard-yaml/compare/v0.1.0...v0.1.1
[0.1.1t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.1.1
[0.1.0]: https://github.com/galtzo-floss/yard-yaml/compare/ffbe883471d11462dc28675867d852372ea3a481...v0.1.0
[0.1.0t]: https://github.com/galtzo-floss/yard-yaml/releases/tag/v0.1.0
