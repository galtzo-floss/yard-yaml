# frozen_string_literal: true

module Yard
  module Yaml
    # Plugin activation for yard-yaml (Phase 3: config + discovery; still no YARD registrations).
    module Plugin
      @activated = false

      class << self
        # Whether the plugin has been activated for the current process.
        # Activation is explicit; requiring this file does not activate anything.
        #
        # @return [Boolean]
        def activated?
          @activated
        end

        # Activate the plugin.
        #
        # Phase 3 behavior:
        # - Parse argv for `--yard_yaml-*` flags and apply to configuration.
        # - Run discovery to collect YAML pages and mirror to registry store.
        # - Do NOT register tags, templates, or handlers yet.
        #
        # @param argv [Array<String>, nil] optional argument vector to parse
        # @return [void]
        def activate(argv = nil)
          # Parse and apply CLI overrides if provided
          begin
            overrides = Cli.parse(argv || [])
            Yard::Yaml.configure(overrides) unless overrides.empty?
          rescue StandardError
            # Parsing failures should not prevent activation in Phase 3
          end

          # Collect pages via discovery using current config
          begin
            pages = Discovery.collect(Yard::Yaml.config)
            Yard::Yaml.__set_pages__(pages)
          rescue Yard::Yaml::Error
            # strict mode surfaced an error; re-raise to fail activation/build
            raise
          rescue StandardError
            # Non-strict errors are already warned by converter/discovery
          end

          @activated = true
          nil
        end

        # Test-helper: reset internal activation flag.
        # Not part of public API; used from test teardown to avoid state leakage.
        def __reset_state__
          @activated = false
          nil
        end
      end
    end
  end
end
