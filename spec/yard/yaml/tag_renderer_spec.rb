# frozen_string_literal: true

RSpec.describe Yard::Yaml::TagRenderer do
  let(:obj) do
    tag_class = Struct.new(:text)
    Class.new do
      def initialize(yaml_blocks: [], yaml_files: [])
        @yaml_blocks = yaml_blocks
        @yaml_files = yaml_files
      end
      define_method(:tag_class) { tag_class }

      def tags(name)
        case name
        when :yaml then @yaml_blocks.map { |t| tag_class.new(t) }
        when :yaml_file then @yaml_files.map { |t| tag_class.new(t) }
        else []
        end
      end
    end
  end

  describe ".render_for" do
    it "returns empty string when object cannot provide tags" do
      expect(described_class.render_for(nil)).to eq("")
      expect(described_class.render_for(Object.new)).to eq("")
    end

    it "returns empty string when object has no relevant tags" do
      html = described_class.render_for(obj.new)
      expect(html).to(eq(""))
    end

    it "treats tag lookup errors as no tags" do
      broken = Class.new do
        def tags(_name)
          raise "tag lookup failed"
        end
      end

      expect(described_class.render_for(broken.new)).to eq("")
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

    it "extracts tag text from name or string fallbacks" do
      name_tag = Struct.new(:name).new("a: 1\n")
      string_tag = Class.new do
        def to_s
          "b: 2\n"
        end
      end.new
      tagged = Class.new do
        define_method(:initialize) { |tags| @tags = tags }
        define_method(:tags) { |name| name == :yaml ? @tags : [] }
      end
      allow(Yard::Yaml::TemplateHelpers).to receive(:render_yaml_block).and_return("<pre>ok</pre>")

      html = described_class.render_for(tagged.new([name_tag, string_tag]))

      expect(Yard::Yaml::TemplateHelpers).to have_received(:render_yaml_block).with("a: 1\n", config: Yard::Yaml.config)
      expect(Yard::Yaml::TemplateHelpers).to have_received(:render_yaml_block).with("b: 2\n", config: Yard::Yaml.config)
      expect(html.scan('class="yyaml-inline"').size).to eq(2)
    end

    it "bubbles up strict errors from TemplateHelpers.render_yaml_file" do
      allow(Yard::Yaml::TemplateHelpers).to receive(:render_yaml_file).and_raise(Yard::Yaml::Error, "boom")
      o = obj.new(yaml_files: ["missing.yml"])
      expect { described_class.render_for(o) }.to raise_error(Yard::Yaml::Error)
    end
  end
end
