# IMPLEMENTATION PLAN — YARD YAML Plugin (HTML from YAML using `yaml-converter`)

Status: Draft
Date: 2025-11-09
Owners: yard-yaml maintainers

This plan breaks the work into discrete, verifiable phases. It adheres to the project’s Development Guidelines (testing, coverage, linting, and docs via YARD). Each phase lists scope, tasks, acceptance criteria, and notes.

## Phase 0 — Project Prep and Scaffolding
Scope: Add dependency, baseline structure, and scaffolding for a YARD plugin without changing behavior yet.

Tasks:
- Update `yard-yaml.gemspec` runtime deps to include `yaml-converter` (minimum version TBD; pin to the latest stable supporting safe load).
- Ensure `yard` is present in development dependencies if not already.
- Establish plugin entry points under `lib/yard/yaml/`:
  - `lib/yard/yaml.rb` (require submodules)
  - `lib/yard/yaml/version.rb`
  - `lib/yard/yaml/plugin.rb` (activation/registration)
  - `lib/yard/yaml/config.rb` (config struct + defaults)
- Add RBS signatures under `sig/yard/yaml/` for any new public APIs.
- Create initial spec files mirroring `lib/` structure.

Acceptance:
- `bundle install` succeeds.
- `bin/rspec` passes with existing specs; coverage thresholds unchanged.
- `bundle exec rake rubocop_gradual:autocorrect && bundle exec rake reek` pass or have only known smells captured in REEK snapshot.

Notes:
- Do not modify `.envrc`. Prefer exporting env vars per-run. Use `K_SOUP_COV_FORMATTERS="json" bin/rspec` to generate coverage locally.

## Phase 1 — Configuration and CLI/opts wiring
Scope: Load and surface configuration from `.yardopts`/ENV and programmatic hooks.

Tasks:
- Implement `Yard::Yaml::Config` with defaults:
  - include: ["docs/**/*.y{a,}ml", "*.y{a,}ml"]
  - exclude: ["**/_*.y{a,}ml"]
  - out_dir: "yaml"
  - index: true
  - toc: "auto"
  - converter_options: {}
  - front_matter: true
  - strict: false
  - allow_erb: false
- Parse `.yardopts` flags with `--yard_yaml-*` to override config.
- Allow programmatic config via `YARD::Registry.store[:yard_yaml_config]` or a documented API method.

Acceptance:
- Unit tests cover default and overridden values.
- Invalid flags emit warnings and are ignored.

Notes:
- Use `rspec-stubbed_env` if any ENV-driven behavior is introduced.

## Phase 2 — Converter Wrapper
Scope: Provide a thin wrapper around `yaml-converter` with safe defaults and a stable API.

Tasks:
- Implement `Yard::Yaml::Converter`:
  - Accept a `String` YAML or a file path.
  - Options mapping to `yaml-converter` (safe load, pretty, wrapping, etc.).
  - Gate any unsafe features (`allow_unsafe`, ERB) behind config.
  - Return a structured result: `{ html:, title:, description:, meta: }`.
- Unit tests exercising success, failure, and edge cases (bad YAML, empty input, front matter only).

Acceptance:
- Converter wrapper returns expected HTML (basic assertions, not deep HTML diffs).
- Errors raise or warn depending on `strict` config.

Notes:
- Keep output deterministic; avoid timestamps in HTML.

## Phase 3 — File Discovery and Registry Integration
Scope: Find YAML files and register them so that templates can render them and navigation can link to them.

Tasks:
- Implement file discovery using include/exclude globs.
- For each discovered file:
  - Convert via `Yard::Yaml::Converter`.
  - Create a `YARD::CodeObjects::ExtraFileObject` (or a custom code object) with metadata (title, path, order).
  - Store results for template phase.
- Generate warnings for missing or unreadable files.

Acceptance:
- When running `yard doc` (with plugin enabled), registry contains extra file objects for all matched YAML files.
- Unit tests confirm object creation and metadata mapping.

Notes:
- Use stable identifiers for objects to enable linking from tags.

## Phase 4 — Templates and Output Emission
Scope: Render converted YAML into the final YARD site under a dedicated directory.

Tasks:
- Register template path: `templates/yard_yaml`.
- Create ERB templates:
  - `yaml_file.erb` for individual YAML pages.
  - `yaml_index.erb` to list all YAML pages.
  - Minimal CSS partial with namespaced classes (e.g., `.yyaml-*`).
- Hook into `YARD::Templates::Engine` to emit files to `<output>/yaml/`.
- Optionally generate per-page TOC when `toc` is enabled.

Acceptance:
- Generated site includes `yaml/index.html` and `yaml/<basename>.html` for each file.
- Pages render titles and descriptions from front matter when present.

Notes:
- Follow YARD default theme styles; keep CSS minimal.

## Phase 5 — Inline Tags (`@yaml` and `@yaml_file`)
Scope: Support inline YAML blocks and references in docstrings.

Tasks:
- Define new tags using `YARD::Tags::Library.define_tag`:
  - `@yaml` (block tag) renders inline converted HTML from the tag body.
  - `@yaml_file path` (text tag) links to or embeds the converted page.
- Extend templates to render these tags in object documentation pages.

Acceptance:
- Example docstrings produce visible, styled output within API docs.
- Missing `@yaml_file` targets produce warnings unless `strict`.

Notes:
- Respect output silencing in tests; tag specs with `:check_output` only when asserting on emitted logs.

## Phase 6 — Indexing, Ordering, and Navigation
Scope: Provide a discoverable index and sensible nav ordering.

Tasks:
- Build a YAML pages index sorted by `nav_order` from front matter or by title.
- Add sidebar group "YAML" with links to pages.
- Ensure breadcrumb/back links follow YARD conventions.

Acceptance:
- Index lists all pages with titles and optional descriptions.
- Sidebar group appears without breaking existing navigation.

## Phase 7 — Error Handling, Strict Mode, and Logging
Scope: Robust behavior across failure modes.

Tasks:
- Implement structured warnings for:
  - Conversion failures
  - Missing files
  - Unsafe options denied by config
- `strict: true` converts these into errors that fail the build.
- Tests covering warning vs error paths and message content.

Acceptance:
- Build continues on non-strict failures; fails on strict.

## Phase 8 — Tests, Coverage, Types, and YARD Docs
Scope: Bring implementation to project standards.

Tasks:
- Unit specs for all public classes/methods; branch coverage for config toggles and error paths.
- Use `include_context 'with stubbed env'` when manipulating ENV-driven behavior.
- Add RBS types in `sig/yard/yaml.rbs` for public APIs.
- Add inline YARD `@param`/`@return` docs for all public methods.

Acceptance:
- `bin/rspec` green with coverage thresholds met.
- `bundle exec rake yard` generates docs including new APIs.

## Phase 9 — Linting, Smell Checks, and Docs Polishing
Scope: Align with static analysis and project documentation rules.

Tasks:
- Run `bundle exec rake rubocop_gradual:autocorrect` and resolve remaining offenses.
- Run `bundle exec rake reek` and update REEK snapshot if intentional smells remain (with justification in CHANGELOG).
- Update `README.md` with usage:
  - Enabling plugin via `.yardopts`
  - Config options and examples
  - Inline tags examples

Acceptance:
- Lint and smell checks pass locally.
- README includes quickstart and configuration examples.

## Phase 10 — Examples and Manual Verification
Scope: Provide a small example set to validate user experience.

Tasks:
- Add sample YAML files under `examples/docs/` (kept small; not part of gem runtime).
- Add a script or documented commands to generate docs locally:
  - `K_SOUP_COV_FORMATTERS="json" bundle exec yard --plugin yard-yaml`
- Verify HTML outputs and links locally.

Acceptance:
- Manual run produces expected HTML pages and inline renderings.

---

## Milestones & Rough Timeline
- M1 (0.1.0): Phases 0–7 complete — core plugin, file conversion, inline tags, index, errors.
- M2 (0.2.0): Phases 8–10 — quality gates, docs, examples.
- M3 (1.0.0): Phase 11–12 — CI matrix (optional), harden API, release.

## Testing Commands Cheat Sheet
- Full suite: `bin/rspec`
- With coverage JSON: `K_SOUP_COV_FORMATTERS="json" bin/rspec`
- Focused example (bypass hard coverage): `K_SOUP_COV_MIN_HARD=false bin/rspec spec/yard/yaml/converter_spec.rb:42`
- Lint: `bundle exec rake rubocop_gradual:autocorrect`
- Smells: `bundle exec rake reek`
- YARD docs: `bundle exec rake yard`

## Risks & Mitigations (Implementation)
- Dependency drift of `yaml-converter`: Pin compatible minor version; add CI to detect breakages.
- Template conflicts: Namespaced assets and isolated template path.
- Performance regressions: Cache by mtime/hash for conversions (defer to 0.2.0 if needed).
