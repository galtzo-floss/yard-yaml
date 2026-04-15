# frozen_string_literal: true

module Yard
  module Yaml
    # Thin wrapper around the yaml-converter gem with safe defaults.
    #
    # Phase 2 scope:
    # - Provide class methods to convert from a YAML string or a file path.
    # - Apply safe defaults and respect config toggles (strict, allow_erb, front_matter).
    # - Delegate conversion to an underlying backend (default: ::Yaml::Converter if available).
    # - Return a normalized result Hash: { html:, title:, description:, meta: }.
    #
    # Note: We intentionally keep the contract minimal and stable. Tests stub the backend.
    class Converter
      BACKEND_STATE = {backend: nil}
      BACKEND_MUTEX = Mutex.new

      class << self
        # Assignable backend for dependency injection in tests.
        # Expected to respond to `convert(yaml, options)` and return a Hash with :html, :title, :description, and :meta keys
        def backend=(backend)
          BACKEND_MUTEX.synchronize { BACKEND_STATE[:backend] = backend }
        end

        # Convert a YAML string into an HTML result.
        #
        # @param yaml [String]
        # @param options [Hash] additional options passed to backend
        # @param config [Yard::Yaml::Config] yard-yaml config (defaults to Yard::Yaml.config)
        # @return [Hash] { html:, title:, description:, meta: }
        def from_string(yaml, options = {}, config: Yard::Yaml.config)
          run_convert(yaml.to_s, options, config)
        end

        # Convert a YAML file from disk.
        #
        # @param path [String]
        # @param options [Hash]
        # @param config [Yard::Yaml::Config]
        # @return [Hash]
        def from_file(path, options = {}, config: Yard::Yaml.config)
          content = read_file(path, config: config)
          return empty_result if content.nil?
          run_convert(content, options.merge(source_path: path.to_s), config)
        end

        # Backend accessor with auto-discovery.
        def backend
          configured_backend = BACKEND_MUTEX.synchronize { BACKEND_STATE[:backend] }
          return configured_backend if configured_backend

          begin
            require "yaml/converter"
          rescue LoadError
            # ignore; backend may be set by tests
          end

          BACKEND_MUTEX.synchronize do
            BACKEND_STATE[:backend] ||= ::Yaml::Converter if defined?(::Yaml) && ::Yaml.const_defined?(:Converter)
          end
        end

        private

        def read_file(path, config: Yard::Yaml.config)
          raw = File.binread(path.to_s)
          if binary_content?(raw)
            handle_error(Yard::Yaml::Error.new("binary file not supported"), strict: config.strict, context: path.to_s)
            return
          end

          content = raw.dup.force_encoding(Encoding::UTF_8)
          return content if content.valid_encoding?

          if config.strict
            handle_error(Yard::Yaml::Error.new("invalid UTF-8 bytes in file"), strict: true, context: path.to_s)
            return
          end

          handle_error(
            Yard::Yaml::Error.new("invalid UTF-8 bytes in file; replaced invalid sequences"),
            strict: false,
            context: path.to_s,
          )
          content.scrub
        rescue Errno::ENOENT => e
          handle_error(e, strict: config.strict, context: "missing file: #{path}")
          nil
        end

        def binary_content?(raw)
          sample = raw.byteslice(0, 4096) || "".b
          return true if sample.include?("\x00")
          return false if sample.empty?

          control_bytes = sample.bytes.count do |byte|
            (0..8).cover?(byte) || byte == 11 || byte == 12 || (14..31).cover?(byte)
          end
          control_bytes.fdiv(sample.bytesize) > 0.1
        end

        def run_convert(yaml, options, config)
          opts = build_options(options, config)
          b = backend
          unless b&.respond_to?(:convert)
            handle_error(Yard::Yaml::Error.new("yaml-converter backend not available"), strict: config.strict, context: "backend")
            return empty_result
          end

          begin
            normalize_result(b.convert(yaml, opts))
          rescue StandardError => e
            handle_error(e, strict: config.strict, context: opts[:source_path] || "string")
            empty_result
          end
        end

        def build_options(options, config)
          safe = {
            allow_erb: !!config.allow_erb,
            front_matter: !!config.front_matter,
          }
          # Merge caller-supplied options and the config's converter_options map (caller wins)
          safe.merge(config.converter_options || {}).merge(options || {})
        end

        def normalize_result(raw)
          return empty_result if raw.nil?
          {
            html: raw[:html] || raw["html"] || "",
            title: raw[:title] || raw["title"],
            description: raw[:description] || raw["description"],
            meta: raw[:meta] || raw["meta"] || {},
          }
        end

        def empty_result
          {html: "", title: nil, description: nil, meta: {}}
        end

        def handle_error(error, strict:, context: nil)
          if strict
            raise Yard::Yaml::Error, error.message
          else
            message = context ? "#{error.class}: #{error.message} (#{context})" : "#{error.class}: #{error.message}"
            if defined?(::Yard) && ::Yard.const_defined?(:Yaml)
              ::Yard::Yaml.__send__(:__warn, message)
            else
              Kernel.warn("yard-yaml: #{message}")
            end
          end
        end
      end
    end
  end
end
