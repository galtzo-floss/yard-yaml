# frozen_string_literal: true

module Yard
  module Yaml
    # Plugin activation for yard-yaml (Phase 3: config + discovery; still no YARD registrations).
    module Plugin
      STATE = {activated: false, at_exit_installed: false}
      STATE_MUTEX = Mutex.new

      class << self
        # Whether the plugin has been activated for the current process.
        # Activation is explicit; requiring this file does not activate anything.
        #
        # @return [Boolean]
        def activated?
          STATE[:activated]
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

          STATE_MUTEX.synchronize { STATE[:activated] = true }
          nil
        end

        # Install an at-exit emitter for YARD's plugin loader. YARD loads
        # plugins before it has generated the HTML tree, so converted YAML
        # pages must be written after YARD finishes.
        #
        # @param argv [Array<String>, nil] the YARD argv used to discover output
        # @return [void]
        def install_at_exit(argv = nil)
          should_install = STATE_MUTEX.synchronize do
            if STATE[:at_exit_installed]
              false
            else
              STATE[:at_exit_installed] = true
            end
          end
          return unless should_install

          at_exit do
            emit!(output_dir: yard_output_dir(argv || ARGV))
          end
          nil
        end

        # Emit converted pages collected during activation.
        #
        # @param output_dir [String] YARD HTML output directory
        # @return [Array<String>]
        def emit!(output_dir:)
          pages = Yard::Yaml.pages
          return [] if pages.nil? || pages.empty?

          Yard::Yaml::Emitter.emit!(pages: pages, output_dir: output_dir, config: Yard::Yaml.config)
        end

        # Resolve YARD's HTML output directory from argv or .yardopts.
        #
        # @param argv [Array<String>]
        # @return [String]
        def yard_output_dir(argv)
          output_dir_from_tokens(Array(argv).map(&:to_s)) ||
            output_dir_from_tokens(yardopts_tokens) ||
            "doc"
        end

        # Test-helper: reset internal activation flag.
        # Not part of public API; used from test teardown to avoid state leakage.
        def __reset_state__
          STATE_MUTEX.synchronize do
            STATE[:activated] = false
            STATE[:at_exit_installed] = false
          end
          nil
        end

        private

        def output_dir_from_tokens(tokens)
          tokens.each_with_index do |token, index|
            return tokens[index + 1] if token == "--output" || token == "-o"
            match = token.match(/\A--output=(.+)\z/)
            return match[1] if match
          end
          nil
        end

        def yardopts_tokens
          return [] unless File.file?(".yardopts")

          require "shellwords"
          Shellwords.split(File.read(".yardopts"))
        rescue StandardError
          []
        end
      end
    end
  end
end
