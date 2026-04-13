# frozen_string_literal: true

RSpec.describe Yard::Yaml::Converter do
  let(:backend) do
    last_result = {}
    Class.new do
      define_singleton_method(:last) { last_result[:value] }
      define_singleton_method(:convert) do |yaml, options|
        last_result[:value] = {yaml: yaml, options: options}
        {
          html: "<p>ok</p>",
          title: options[:title] || "Title",
          description: "Desc",
          meta: {source: options[:source_path]},
        }
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
      expect(backend.last[:options]["pretty"]).to(be(false))
      expect(backend.last[:options][:source_path]).to(eq(file.path))
    ensure
      file.close
      file.unlink
    end
  end

  it "preserves emoji and kanji when converting from file" do
    file = Tempfile.new(["yyaml-utf8", ".yml"])
    begin
      file.binmode
      file.write("title: \"🌸 こんにちは\"\nbody: \"emoji 😀\"\n")
      file.flush

      described_class.from_file(file.path)
      expect(backend.last[:yaml]).to include("🌸 こんにちは")
      expect(backend.last[:yaml]).to include("emoji 😀")
    ensure
      file.close
      file.unlink
    end
  end

  it "scrubs malformed utf-8 bytes in non-strict mode and warns", :check_output do
    file = Tempfile.new(["yyaml-bad", ".yml"])
    begin
      file.binmode
      file.write("title: bad\xFF\nbody: still here\n")
      file.flush
      Yard::Yaml.configure(strict: false)

      output = capture(:stderr) { described_class.from_file(file.path) }

      expect(output).to include("yard-yaml:")
      expect(backend.last[:yaml]).to include("title: bad\ufffd")
      expect(backend.last[:yaml]).to include("body: still here")
    ensure
      file.close
      file.unlink
    end
  end

  it "raises Yard::Yaml::Error for malformed utf-8 bytes in strict mode" do
    file = Tempfile.new(["yyaml-bad-strict", ".yml"])
    begin
      file.binmode
      file.write("title: bad\xFF\n")
      file.flush
      Yard::Yaml.configure(strict: true)

      expect { described_class.from_file(file.path) }.to raise_error(Yard::Yaml::Error, /invalid UTF-8 bytes/)
    ensure
      file.close
      file.unlink
    end
  end

  it "returns empty result and warns for binary-ish files in non-strict mode", :check_output do
    file = Tempfile.new(["yyaml-binary", ".yml"])
    begin
      file.binmode
      file.write("\x00\x01\x02\x03binary".b)
      file.flush
      Yard::Yaml.configure(strict: false)

      output = capture(:stderr) do
        result = described_class.from_file(file.path)
        expect(result).to eq(html: "", title: nil, description: nil, meta: {})
      end

      expect(output).to include("yard-yaml:")
      expect(output).to include("binary file not supported")
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
