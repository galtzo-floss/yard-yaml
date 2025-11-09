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
- Inline tag rendering for `@yaml` and `@yaml_file`, placed inline in object docstrings via template hooks.
- Sidebar group "YAML Docs" listing discovered pages with deterministic ordering.
- File discovery ordering by `meta.nav_order` (numeric) → title (case-insensitive) → path.
- Unified logging helpers `Yard::Yaml.warn` and `Yard::Yaml.error` with fallback to `Kernel.warn`.
- Emitter to write per-page HTML and optional index, with stable slugs via `Emitter.slug_for`.
- Examples under `examples/docs/` for manual verification.
- Additional specs increasing coverage of slugs and write-error warnings.

### Changed
- Converter/Discovery/Emitter/CLI now route warnings through unified helpers; strict mode behavior standardized.

### Deprecated
- None.

### Removed
- None.

### Fixed
- Reduced noisy constant redefinition in tag registration in most contexts (tests still exercise re-registration).

### Security
- Safe defaults maintained; ERB remains disabled by default; strict mode converts warnings to errors.

## [0.1.0] - 2025-11-08

- Initial release
