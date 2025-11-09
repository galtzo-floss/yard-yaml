# frozen_string_literal: true

module Yard
  module Yaml
    # CLI helpers to parse `.yardopts`/argv flags for yard-yaml.
    #
    # Phase 1: Only parses configuration flags and returns a Hash suitable for
    # Yard::Yaml::Config#apply. It does not mutate global state.
    module Cli
      PREFIX = "--yard_yaml-"
      NO_PREFIX = "--no-yard_yaml-"

      class << self
        # Parse argv for yard-yaml flags.
        #
        # Supported flags:
        # - --yard_yaml-include <glob> (repeatable)
        # - --yard_yaml-exclude <glob> (repeatable)
        # - --yard_yaml-out_dir <dir>
        # - --yard_yaml-index[=true|false] | --no-yard_yaml-index
        # - --yard_yaml-front_matter[=true|false] | --no-yard_yaml-front_matter
        # - --yard_yaml-strict[=true|false] | --no-yard_yaml-strict
        # - --yard_yaml-allow_erb[=true|false] | --no-yard_yaml-allow_erb
        # - --yard_yaml-toc <mode>
        # - --yard_yaml-converter_options key:value[,key:value]
        #
        # @param argv [Array<String>]
        # @return [Hash] normalized overrides
        def parse(argv)
          return {} if argv.nil? || argv.empty?

          overrides = {}
          i = 0
          while i < argv.length
            token = argv[i]

            if token.start_with?(NO_PREFIX)
              key = token.delete_prefix(NO_PREFIX).to_sym
              apply_bool(overrides, key, false)
              i += 1
              next
            end

            unless token.start_with?(PREFIX)
              i += 1
              next
            end

            # handle --flag=value form
            if token.include?("=")
              flag, raw = token.split("=", 2)
              key = flag.delete_prefix(PREFIX).to_sym
              apply_kv(overrides, key, raw)
              i += 1
              next
            end

            key = token.delete_prefix(PREFIX).to_sym

            case key
            when :include, :exclude
              value = argv[i + 1]
              if value.nil? || value.start_with?("--")
                warn_unknown("missing value for #{token}")
                i += 1
              else
                arr = (overrides[key] ||= [])
                arr << value.to_s
                i += 2
              end
            when :out_dir, :toc
              value = argv[i + 1]
              if value.nil? || value.start_with?("--")
                warn_unknown("missing value for #{token}")
                i += 1
              else
                overrides[key] = value.to_s
                i += 2
              end
            when :index, :front_matter, :strict, :allow_erb
              # Bare presence means true
              apply_bool(overrides, key, true)
              i += 1
            when :converter_options
              value = argv[i + 1]
              if value.nil? || value.start_with?("--")
                warn_unknown("missing value for #{token}")
                i += 1
              else
                overrides[:converter_options] = parse_converter_options(value)
                i += 2
              end
            else
              warn_unknown("unknown flag #{token}")
              i += 1
            end
          end

          overrides
        end

        private

        def apply_kv(overrides, key, raw)
          case key
          when :include, :exclude
            arr = (overrides[key] ||= [])
            arr << raw.to_s
          when :out_dir, :toc
            overrides[key] = raw.to_s
          when :index, :front_matter, :strict, :allow_erb
            apply_bool(overrides, key, coerce_bool(raw))
          when :converter_options
            overrides[:converter_options] = parse_converter_options(raw)
          else
            warn_unknown("unknown flag --yard_yaml-#{key}")
          end
        end

        def apply_bool(overrides, key, value)
          overrides[key] = !!value
        end

        def coerce_bool(value)
          case value.to_s.strip.downcase
          when "", "true", "1", "yes", "y", "on" then true
          when "false", "0", "no", "n", "off" then false
          else
            warn_unknown("invalid boolean '#{value}'")
            false
          end
        end

        def parse_converter_options(raw)
          result = {}
          raw.to_s.split(",").each do |pair|
            k, v = pair.split(":", 2)
            if k.nil? || v.nil?
              warn_unknown("invalid converter option '#{pair}'")
              next
            end
            result[k.to_s] = coerce_scalar(v)
          end
          result
        end

        def coerce_scalar(v)
          s = v.to_s
          low = s.strip.downcase
          return true if %w[true yes y on 1].include?(low)
          return false if %w[false no n off 0].include?(low)
          begin
            return Integer(s)
          rescue
            nil
          end if s.match?(/\A[+-]?\d+\z/)
          begin
            return Float(s)
          rescue
            nil
          end if s.match?(/\A[+-]?(?:\d+\.)?\d+\z/)
          s
        end

        def warn_unknown(message)
          # Delegate to unified helper to avoid NameError when a partial YARD stub exists.
          if defined?(::Yard) && ::Yard.const_defined?(:Yaml)
            ::Yard::Yaml.warn(message)
          else
            Kernel.warn("yard-yaml: #{message}")
          end
        end
      end
    end
  end
end
