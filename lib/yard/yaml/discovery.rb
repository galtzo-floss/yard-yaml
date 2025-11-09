# frozen_string_literal: true

module Yard
  module Yaml
    # Discovery helpers to find YAML files and collect converted pages.
    #
    # Phase 3 scope:
    # - Discover files via include/exclude globs from config.
    # - Convert files via Converter and return normalized page hashes.
    # - Errors are handled by Converter according to config.strict.
    module Discovery
      class << self
        # Find YAML files using include and exclude patterns.
        # Patterns are evaluated relative to the current working directory.
        #
        # @param include_globs [Array<String>]
        # @param exclude_globs [Array<String>]
        # @return [Array<String>] sorted list of file paths
        def find_files(include_globs, exclude_globs)
          incs = Array(include_globs).compact
          excs = Array(exclude_globs).compact

          files = []
          incs.each do |glob|
            next if glob.nil? || glob.to_s.strip.empty?
            Dir.glob(glob.to_s, File::FNM_CASEFOLD | File::FNM_EXTGLOB | File::FNM_PATHNAME).each do |path|
              next unless File.file?(path)
              files << path
            end
          end

          files.uniq!

          unless excs.empty?
            files.select! do |path|
              excs.none? { |pat| File.fnmatch?(pat.to_s, path, File::FNM_PATHNAME | File::FNM_EXTGLOB | File::FNM_CASEFOLD) }
            end
          end

          files.sort.map { |p| File.expand_path(p) }
        end

        # Collect pages by converting discovered files.
        #
        # @param config [Yard::Yaml::Config]
        # @return [Array<Hash>] Array of page hashes: { path:, html:, title:, description:, meta: }
        def collect(config = Yard::Yaml.config)
          files = find_files(config.include, config.exclude)
          results = []

          files.each do |path|
            converted = Yard::Yaml::Converter.from_file(path, {}, config: config)
            results << {
              path: path,
              html: converted[:html],
              title: converted[:title],
              description: converted[:description],
              meta: converted[:meta] || {},
            }
          rescue Yard::Yaml::Error
            # In strict mode Converter will raise; re-raise to fail the build
            raise
          rescue StandardError => e
            # Non-strict converter errors are already warned; skip file
            warn_fallback("skipping #{path}: #{e.class}: #{e.message}")
          end

          # Deterministic ordering by nav_order (if present) then title then path.
          # nav_order values sort numerically; missing/non-numeric values are treated as Infinity (i.e., after any numeric ones).
          results.sort_by { |h| [nav_order_value(h[:meta]), h[:title].to_s.downcase, h[:path]] }
        end

        private

        # Extract a numeric nav_order from meta. Returns Infinity when absent or non-numeric
        # so those entries sort after any numeric ones.
        def nav_order_value(meta)
          return Float::INFINITY unless meta.is_a?(Hash)
          val = meta[:nav_order] || meta["nav_order"]
          case val
          when Integer, Float
            val
          when String
            s = val.strip
            if s.match?(/\A[+-]?\d+\z/)
              begin
                Integer(s)
              rescue
                Float::INFINITY
              end
            elsif s.match?(/\A[+-]?(?:\d+\.)?\d+\z/)
              begin
                Float(s)
              rescue
                Float::INFINITY
              end
            else
              Float::INFINITY
            end
          else
            Float::INFINITY
          end
        rescue StandardError
          Float::INFINITY
        end

        def warn_fallback(message)
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
