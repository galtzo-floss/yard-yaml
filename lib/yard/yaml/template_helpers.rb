# frozen_string_literal: true

module Yard
  module Yaml
    # View/template helpers for rendering YAML blocks and files.
    #
    # Phase 5 scope:
    # - Provide simple helpers independent of YARD templates so they are unit-testable.
    # - Use Converter with current config and safe defaults.
    # - For files: resolve relative paths against a provided base_dir (default: Dir.pwd).
    module TemplateHelpers
      module_function

      # Render inline YAML text to HTML via Converter.
      #
      # @param text [String] YAML content
      # @param config [Yard::Yaml::Config]
      # @return [String] HTML fragment
      def render_yaml_block(text, config: Yard::Yaml.config)
        res = Yard::Yaml::Converter.from_string(text.to_s, {}, config: config)
        res[:html].to_s
      end

      # Render a YAML file to HTML via Converter.
      #
      # @param path [String] file path (absolute or relative)
      # @param base_dir [String] base directory to resolve relative paths against (default: Dir.pwd)
      # @param config [Yard::Yaml::Config]
      # @return [String] HTML fragment (empty on non-strict missing file)
      def render_yaml_file(path, base_dir: Dir.pwd, config: Yard::Yaml.config)
        resolved = resolve_path(path, base_dir)
        res = Yard::Yaml::Converter.from_file(resolved, {}, config: config)
        res[:html].to_s
      rescue Yard::Yaml::Error
        # strict mode errors bubble from converter; re-raise
        raise
      rescue StandardError => e
        # Non-strict paths should already be handled by converter; this is a last-resort guard.
        if defined?(::Yard) && ::Yard.const_defined?(:Yaml)
          ::Yard::Yaml.warn("#{e.class}: #{e.message} while rendering #{path}")
        else
          Kernel.warn("yard-yaml: #{e.class}: #{e.message} while rendering #{path}")
        end
        ""
      end

      # Resolve a path relative to base_dir when necessary.
      # @api private
      def resolve_path(path, base_dir)
        p = path.to_s
        return p if p.start_with?("/") || p.match?(/^[A-Za-z]:[\\\/]?/) # absolute on unix or windows
        File.expand_path(File.join(base_dir.to_s, p))
      end
      private_class_method :resolve_path
    end
  end
end
