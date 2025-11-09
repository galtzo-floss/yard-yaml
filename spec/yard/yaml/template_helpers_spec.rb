# frozen_string_literal: true

RSpec.describe Yard::Yaml::TemplateHelpers do
  let(:backend) do
    Class.new do
      class << self
        def convert(yaml, options)
          { html: "<pre>#{yaml.strip}</pre>", title: options[:title], description: nil, meta: {} }
        end
      end
    end
  end

  before do
    Yard::Yaml::Converter.backend = backend
  end

  describe ".render_yaml_block" do
    it "returns converter html for inline yaml" do
      html = described_class.render_yaml_block("a: 1\n")
      expect(html).to(eq("<pre>a: 1</pre>"))
    end
  end

  describe ".render_yaml_file" do
    it "renders a file and returns html" do
      file = Tempfile.new(["yyaml", ".yml"])
      begin
        file.write("b: 2\n")
        file.flush
        html = described_class.render_yaml_file(File.basename(file.path), base_dir: File.dirname(file.path))
        expect(html).to(eq("<pre>b: 2</pre>"))
      ensure
        file.close
        file.unlink
      end
    end

    it "returns empty string on missing file in non-strict mode", :check_output do
      Yard::Yaml.configure(strict: false)
      missing = described_class.render_yaml_file("/no/such.yml")
      expect(missing).to(eq(""))
    end

    it "raises Yard::Yaml::Error when strict and file missing" do
      Yard::Yaml.configure(strict: true)
      expect { described_class.render_yaml_file("/nope.yml") }.to(raise_error(Yard::Yaml::Error))
    end
  end
end
