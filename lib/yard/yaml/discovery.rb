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
            begin
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
          end

          # Deterministic ordering by title then path, falling back as needed
          results.sort_by { |h| [h[:title].to_s.downcase, h[:path]] }
        end

        private

        def warn_fallback(message)
          if defined?(::YARD) && ::YARD.const_defined?(:Logger)
            ::YARD::Logger.instance.warn("yard-yaml: #{message}")
          else
            Kernel.warn("yard-yaml: #{message}")
          end
        end
      end
    end
  end
end
