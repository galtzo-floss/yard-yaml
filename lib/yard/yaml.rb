# frozen_string_literal: true

require_relative "yaml/version"
require_relative "yaml/config"
require_relative "yaml/cli"
require_relative "yaml/plugin"
require_relative "yaml/converter"
require_relative "yaml/discovery"

module Yard
  module Yaml
    # Generic error for yard-yaml
    class Error < StandardError; end

    @config = nil
    @pages = nil

    class << self
      # Access the global configuration for yard-yaml.
      #
      # Returns a memoized instance. It is safe to mutate via accessors in
      # controlled contexts (e.g., tests or explicit configuration blocks).
      #
      # @return [Yard::Yaml::Config]
      def config
        @config ||= Config.new
      end

      # Access collected pages (Phase 3). Nil until plugin activation performs discovery.
      # Each page is a Hash with keys: :path, :html, :title, :description, :meta
      # @return [Array<Hash>, nil]
      def pages
        @pages
      end

      # Internal: set collected pages (used by Plugin during activation)
      def __set_pages__(list)
        @pages = Array(list)
        mirror_pages_to_registry(@pages)
        @pages
      end

      # Configure the plugin programmatically.
      #
      # @param overrides [Hash,nil] optional overrides to apply
      # @yieldparam cfg [Yard::Yaml::Config] the live config instance
      # @return [Yard::Yaml::Config] the resulting config
      def configure(overrides = nil)
        cfg = config
        cfg.apply(overrides) if overrides && !overrides.empty?
        yield(cfg) if block_given?
        mirror_to_registry(cfg)
        cfg
      end

      # Test-helper: reset memoized config to defaults (not public API)
      def __reset_state__
        @config = nil
        @pages = nil
        if defined?(::Yard::Yaml::Plugin) && ::Yard::Yaml::Plugin.respond_to?(:__reset_state__)
          ::Yard::Yaml::Plugin.__reset_state__
        end
        nil
      end

      private

      def mirror_to_registry(cfg)
        return unless defined?(::YARD) && ::YARD.const_defined?(:Registry)
        # Registry.store is a Hash-like; avoid raising if unavailable
        begin
          ::YARD::Registry.store[:yard_yaml_config] = cfg
        rescue StandardError
          # ignore if registry store not ready
        end
      end

      def mirror_pages_to_registry(pages)
        return unless defined?(::YARD) && ::YARD.const_defined?(:Registry)
        begin
          ::YARD::Registry.store[:yard_yaml_pages] = pages
        rescue StandardError
          # ignore if registry store not ready
        end
      end
    end
  end
end
