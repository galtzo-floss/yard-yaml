# frozen_string_literal: true

require "fileutils"

module Yard
  module Yaml
    # Writes converted YAML pages to the YARD output directory.
    #
    # Phase 4 scope:
    # - Emits per-page HTML files under <output>/<config.out_dir>/
    # - Optionally emits an index.html when config.index is true
    # - Keeps implementation independent of YARD internals; caller passes output_dir
    # - Deterministic filenames and ordering
    #
    # This class purposefully uses a tiny built-in template to keep behavior
    # deterministic for tests. In a later phase, we can wire ERB templates via
    # YARD::Templates::Engine and theme hooks.
    class Emitter
      class << self
        # Emit all pages to disk.
        #
        # @param pages [Array<Hash>] normalized pages with keys :path, :html, :title, :description, :meta
        # @param output_dir [String] the YARD output directory (typically `YARD::Registry.yardoc_file`/`YARD::Templates::Engine.generate` destination)
        # @param config [Yard::Yaml::Config]
        # @return [Array<String>] list of written file paths
        def emit!(pages:, output_dir:, config: Yard::Yaml.config)
          pages = Array(pages)
          pages_with_slugs = assign_slugs(pages)
          written = []
          base = File.join(output_dir.to_s, config.out_dir.to_s)
          FileUtils.mkdir_p(base)

          # Write per-page files
          pages_with_slugs.each do |page|
            slug = page.fetch(:__yard_yaml_slug)
            path = File.join(base, "#{slug}.html")
            html = render_page_html(page)
            atomic_write(path, html, strict: config.strict)
            written << path
          end

          # Index (optional)
          if config.index
            index_path = File.join(base, "index.html")
            html = render_index_html(pages_with_slugs)
            atomic_write(index_path, html, strict: config.strict)
            written << index_path
          end

          written
        end

        # Public: derive a stable slug for a page hash. Shared by templates.
        # @param page [Hash]
        # @return [String]
        def slug_for(page)
          page_slug(page)
        end

        private

        def assign_slugs(pages)
          seen = Hash.new(0)
          pages.map do |page|
            slug = page_slug(page)
            count = seen[slug]
            seen[slug] += 1
            page.merge(__yard_yaml_slug: count.zero? ? slug : "#{slug}-#{count + 1}")
          end
        end

        def page_slug(page)
          meta = page[:meta] || {}
          slug = meta["slug"] || meta[:slug]
          return sanitize_slug(slug) if slug && !slug.to_s.empty?

          if page[:path]
            path_slug = path_slug(page[:path])
            return path_slug unless path_slug.empty?
          end

          title = sanitize_slug(page[:title])
          title.empty? ? "page" : title
        end

        def path_slug(path)
          relative = path.to_s.delete_prefix("#{Dir.pwd}/")
          dirname = File.dirname(relative)
          basename = File.basename(relative, File.extname(relative))
          parts = (dirname == ".") ? [basename] : dirname.split(File::SEPARATOR) + [basename]
          sanitize_slug(parts.join("-"))
        end

        def sanitize_slug(s)
          s.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
        end

        def render_page_html(page)
          title = page[:title] || "Untitled"
          desc = page[:description]
          body = page[:html].to_s
          <<~HTML
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1" />
              <title>#{escape_html(title)}</title>
              <style>
                /* minimal, namespaced styles */
                .yyaml-page { font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif; }
                .yyaml-title { margin: 0.2em 0 0.4em; font-size: 1.6em; }
                .yyaml-desc { color: #444; margin-bottom: 1em; }
                .yyaml-body { line-height: 1.5; }
              </style>
            </head>
            <body class="yyaml-page">
              <h1 class="yyaml-title">#{escape_html(title)}</h1>
              #{"<p class=\"yyaml-desc\">#{escape_html(desc)}</p>" if desc}
              <div class="yyaml-body">#{body}</div>
            </body>
            </html>
          HTML
        end

        def render_index_html(pages)
          rows = pages.map do |p|
            slug = p[:__yard_yaml_slug] || page_slug(p)
            title = p[:title] || slug
            desc = p[:description]
            %(<li><a href="#{escape_html(slug)}.html">#{escape_html(title)}</a>#{" — #{escape_html(desc)}" if desc}</li>)
          end.join("\n")

          <<~HTML
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1" />
              <title>YAML Index</title>
              <style>
                .yyaml-index { font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif; }
                .yyaml-index h1 { font-size: 1.8em; }
                .yyaml-index ul { list-style: disc; padding-left: 1.4em; }
              </style>
            </head>
            <body class="yyaml-index">
              <h1>YAML Documents</h1>
              <ul>
                #{rows}
              </ul>
            </body>
            </html>
          HTML
        end

        def atomic_write(path, content, strict: false)
          dir = File.dirname(path)
          FileUtils.mkdir_p(dir)
          tmp = File.join(dir, ".#{$$}.#{Time.now.to_i}.tmp")
          File.open(tmp, "wb") { |f| f.write(content.to_s) }
          FileUtils.mv(tmp, path)
        rescue StandardError => e
          message = "write failed for #{path}: #{e.message}"
          if strict
            raise Yard::Yaml::Error, message
          elsif defined?(::Yard) && ::Yard.const_defined?(:Yaml)
            ::Yard::Yaml.warn(message)
          else
            Kernel.warn("yard-yaml: #{message}")
          end
        ensure
          begin
            FileUtils.rm_f(tmp) if tmp && File.exist?(tmp)
          rescue StandardError
            # ignore
          end
        end

        def escape_html(s)
          s.to_s
            .gsub("&", "&amp;")
            .gsub("<", "&lt;")
            .gsub(">", "&gt;")
            .gsub('"', "&quot;")
            .gsub("'", "&#39;")
        end
      end
    end
  end
end
