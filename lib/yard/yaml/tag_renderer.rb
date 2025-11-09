# frozen_string_literal: true

module Yard
  module Yaml
    # Renders HTML fragments for @yaml (inline block) and @yaml_file tags
    # found on a YARD code object. This is a small, YARD-agnostic utility
    # that can be called from templates. It does not depend on YARD internals
    # beyond the code object responding to `tags(:name)`.
    #
    # Phase 5: This provides the wiring surface needed by templates. Actual
    # template hook-up can call {TagRenderer.render_for(object, ...)}.
    module TagRenderer
      module_function

      # Render YAML-related tags on a code object into a single HTML fragment.
      #
      # @param object [#tags] a YARD code object (or duck-typed test double)
      # @param base_dir [String] base directory to resolve @yaml_file paths
      # @param config [Yard::Yaml::Config]
      # @return [String] HTML fragment (may be empty string)
      def render_for(object, base_dir: Dir.pwd, config: Yard::Yaml.config)
        return "" unless object && object.respond_to?(:tags)

        parts = []

        # Inline @yaml blocks (text of the tag is treated as YAML)
        fetch_tags(object, :yaml).each do |tag|
          yaml_text = extract_text(tag)
          next if yaml_text.nil? || yaml_text.strip.empty?
          html = Yard::Yaml::TemplateHelpers.render_yaml_block(yaml_text, config: config)
          parts << wrap_section(html, kind: :yaml)
        end

        # @yaml_file path
        fetch_tags(object, :yaml_file).each do |tag|
          path = extract_text(tag)
          next if path.nil? || path.strip.empty?
          html = Yard::Yaml::TemplateHelpers.render_yaml_file(path, base_dir: base_dir, config: config)
          parts << wrap_section(html, kind: :yaml_file)
        end

        parts.join("\n")
      end

      # --- internal helpers ---

      def fetch_tags(object, name)
        object.tags(name) || []
      rescue StandardError
        []
      end
      module_function :fetch_tags

      def extract_text(tag)
        return tag.text if tag.respond_to?(:text)
        # Some YARD tags use #name or #to_s; fall back sensibly
        return tag.name.to_s if tag.respond_to?(:name)
        tag.to_s
      end
      module_function :extract_text

      def wrap_section(html, kind:)
        return "" if html.to_s.empty?
        css = (kind == :yaml) ? "yyaml-inline" : "yyaml-file"
        %(<div class="#{css}">#{html}</div>)
      end
      module_function :wrap_section
    end
  end
end
