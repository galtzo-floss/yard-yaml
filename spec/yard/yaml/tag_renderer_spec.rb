# frozen_string_literal: true

RSpec.describe Yard::Yaml::TagRenderer do
  let(:obj) do
    Class.new do
      def initialize(yaml_blocks: [], yaml_files: [])
        @yaml_blocks = yaml_blocks
        @yaml_files = yaml_files
      end
      Tag = Struct.new(:text)
      def tags(name)
        case name
        when :yaml then @yaml_blocks.map { |t| Tag.new(t) }
        when :yaml_file then @yaml_files.map { |t| Tag.new(t) }
        else []
        end
      end
    end
  end

  describe ".render_for" do
    it "returns empty string when object has no relevant tags" do
      html = described_class.render_for(obj.new)
      expect(html).to(eq(""))
    end

    it "renders inline @yaml blocks using TemplateHelpers and wraps output" do
      allow(Yard::Yaml::TemplateHelpers).to receive(:render_yaml_block).and_return("<pre>ok</pre>")
      o = obj.new(yaml_blocks: ["a: 1\n"])
      html = described_class.render_for(o)
      expect(Yard::Yaml::TemplateHelpers).to have_received(:render_yaml_block).with("a: 1\n", config: Yard::Yaml.config)
      expect(html).to include('<div class="yyaml-inline">')
      expect(html).to include("<pre>ok</pre>")
    end

    it "renders @yaml_file entries using TemplateHelpers, resolves and wraps output" do
      allow(Yard::Yaml::TemplateHelpers).to receive(:render_yaml_file).and_return("<p>file</p>")
      o = obj.new(yaml_files: ["docs/x.yml"])
      html = described_class.render_for(o, base_dir: Dir.pwd)
      expect(Yard::Yaml::TemplateHelpers).to have_received(:render_yaml_file).with("docs/x.yml", base_dir: Dir.pwd, config: Yard::Yaml.config)
      expect(html).to include('<div class="yyaml-file">')
      expect(html).to include("<p>file</p>")
    end

    it "bubbles up strict errors from TemplateHelpers.render_yaml_file" do
      allow(Yard::Yaml::TemplateHelpers).to receive(:render_yaml_file).and_raise(Yard::Yaml::Error, "boom")
      o = obj.new(yaml_files: ["missing.yml"])
      expect { described_class.render_for(o) }.to raise_error(Yard::Yaml::Error)
    end
  end
end
