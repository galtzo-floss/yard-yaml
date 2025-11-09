# frozen_string_literal: true

module Yard
  module Yaml
    # Configuration for the yard-yaml plugin.
    #
    # Phase 0: This is a data holder only; wiring into YARD will happen in later phases.
    #
    # Defaults are intentionally conservative and match the PRD/plan.
    # Nothing here modifies YARD behavior when merely required.
    class Config
      # Default glob patterns to include during discovery.
      DEFAULT_INCLUDE = [
        "docs/**/*.y{a,}ml",
        "*.y{a,}ml",
      ].freeze

      # Default glob patterns to exclude during discovery.
      DEFAULT_EXCLUDE = [
        "**/_*.y{a,}ml",
      ].freeze

      # Directory (under YARD output) where converted pages will be written.
      DEFAULT_OUT_DIR = "yaml"

      # Whether to generate an index page for YAML documents.
      DEFAULT_INDEX = true

      # Table of contents generation strategy.
      # "auto" defers to converter/page size; additional options may be added later.
      DEFAULT_TOC = "auto"

      # Options forwarded to yaml-converter.
      DEFAULT_CONVERTER_OPTIONS = {}.freeze

      # Whether to respect YAML front matter for title/nav order.
      DEFAULT_FRONT_MATTER = true

      # When true, errors are raised and should fail the build (later phases).
      DEFAULT_STRICT = false

      # Whether to allow ERB processing inside YAML (disabled by default for safety).
      DEFAULT_ALLOW_ERB = false

      attr_accessor :include,
        :exclude,
        :out_dir,
        :index,
        :toc,
        :converter_options,
        :front_matter,
        :strict,
        :allow_erb

      # Create a new Config with defaults, optionally overridden via a hash.
      #
      # @param overrides [Hash] optional overrides for any attribute
      def initialize(overrides = {})
        @include = DEFAULT_INCLUDE.dup
        @exclude = DEFAULT_EXCLUDE.dup
        @out_dir = DEFAULT_OUT_DIR.dup
        @index = DEFAULT_INDEX
        @toc = DEFAULT_TOC.dup
        @converter_options = DEFAULT_CONVERTER_OPTIONS.dup
        @front_matter = DEFAULT_FRONT_MATTER
        @strict = DEFAULT_STRICT
        @allow_erb = DEFAULT_ALLOW_ERB

        apply(overrides) unless overrides.nil? || overrides.empty?
      end

      # Apply a set of overrides to this config instance.
      # Unknown keys are ignored in Phase 0 (later phases may warn).
      #
      # @param hash [Hash]
      # @return [self]
      def apply(hash)
        hash.each do |key, value|
          case key.to_sym
          when :include then @include = Array(value).map(&:to_s)
          when :exclude then @exclude = Array(value).map(&:to_s)
          when :out_dir then @out_dir = value.to_s
          when :index then @index = coerce_bool(value)
          when :toc then @toc = value.to_s
          when :converter_options then @converter_options = value || {}
          when :front_matter then @front_matter = coerce_bool(value)
          when :strict then @strict = coerce_bool(value)
          when :allow_erb then @allow_erb = coerce_bool(value)
          else
            # Intentionally ignore unknown keys in Phase 0
          end
        end
        self
      end

      private

      # Coerce various truthy/falsey representations to a boolean.
      # Accepts common string/number forms used in CLI and config files.
      def coerce_bool(value)
        case value
        when true then true
        when false, nil then false
        when Integer
          return true if value == 1
          return false if value == 0
          !!value
        else
          str = value.to_s.strip.downcase
          return true if %w[true 1 yes y on].include?(str)
          return false if %w[false 0 no n off].include?(str)
          # Fallback to Ruby truthiness for anything else
          !!value
        end
      end
    end
  end
end
