# frozen_string_literal: true

RSpec.describe Yard::Yaml::Converter do
  let(:backend) do
    Class.new do
      class << self
        attr_accessor :last
        def convert(yaml, options)
          self.last = {yaml: yaml, options: options}
          {
            html: "<p>ok</p>",
            title: options[:title] || "Title",
            description: "Desc",
            meta: {source: options[:source_path]},
          }
        end
      end
    end
  end

  before do
    described_class.backend = backend
  end

  it "converts from string with safe defaults" do
    result = described_class.from_string("a: 1\n")
    expect(result[:html]).to(eq("<p>ok</p>"))
    expect(result[:title]).to(eq("Title"))
    expect(result[:description]).to(eq("Desc"))
    expect(result[:meta]).to(eq({source: nil}))
    # ensure options included from config
    expect(backend.last[:options]).to(include(:allow_erb, :front_matter))
  end

  it "converts from file and passes source_path and merged options" do
    file = Tempfile.new(["yyaml", ".yml"])
    begin
      file.write("a: 2\n")
      file.flush
      Yard::Yaml.configure(converter_options: {"wrap" => 80, "pretty" => false})
      result = described_class.from_file(file.path, {"wrap" => 100, :title => "Hello"})
      expect(result[:html]).to(eq("<p>ok</p>"))
      expect(result[:title]).to(eq("Hello"))
      expect(backend.last[:options]["wrap"]).to(eq(100)) # caller overrides config
      expect(backend.last[:options]["pretty"]).to(eq(false))
      expect(backend.last[:options][:source_path]).to(eq(file.path))
    ensure
      file.close
      file.unlink
    end
  end

  it "returns empty result and warns when backend missing (non-strict)", :check_output do
    described_class.backend = nil
    Yard::Yaml.configure(strict: false)
    output = capture(:stderr) {
      res = described_class.from_string("bad")
      expect(res[:html]).to(eq(""))
    }
    expect(output).to(include("yard-yaml:"))
  end

  it "raises Yard::Yaml::Error when strict and backend missing" do
    described_class.backend = nil
    Yard::Yaml.configure(strict: true)
    expect { described_class.from_string("data") }.to(raise_error(Yard::Yaml::Error))
  end

  it "warns and returns empty result when file does not exist (non-strict)", :check_output do
    described_class.backend = backend
    Yard::Yaml.configure(strict: false)
    output = capture(:stderr) {
      res = described_class.from_file("/no/such/file.yml")
      expect(res[:html]).to(eq(""))
    }
    expect(output).to(include("yard-yaml:"))
  end
end
