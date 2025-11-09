# frozen_string_literal: true

RSpec.describe Yard::Yaml::Discovery do
  let(:tmpdir) { File.join(Dir.pwd, "tmp", "yyaml_discovery_strict_spec") }

  before do
    FileUtils.rm_rf(tmpdir)
    FileUtils.mkdir_p(File.join(tmpdir, "docs"))
  end

  after do
    FileUtils.rm_rf(tmpdir)
  end

  def write(path, content = "---\ntitle: T\n---\nbody: v\n")
    full = File.join(tmpdir, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
    full
  end

  it "continues with warnings in non-strict mode when a file conversion fails", :check_output do
    a = write("docs/a.yml")
    b = write("docs/b.yml")
    bad = write("docs/bad.yml")

    allow(Yard::Yaml::Converter).to receive(:from_file) do |path, *_args|
      case path
      when a then {html: "<p>a</p>", title: "A", description: nil, meta: {}}
      when b then {html: "<p>b</p>", title: "B", description: nil, meta: {}}
      when bad then raise StandardError, "boom"
      else {html: "", title: File.basename(path), description: nil, meta: {}}
      end
    end

    cfg = Yard::Yaml::Config.new(include: [File.join(tmpdir, "docs/**/*.yml")], exclude: [], strict: false)
    output = capture(:stderr) do
      pages = described_class.collect(cfg)
      titles = pages.map { |p| p[:title] }
      expect(titles).to include("A", "B")
      expect(titles).not_to include("bad")
    end
    expect(output).to include("yard-yaml:")
    expect(output).to include("skipping")
  end

  it "raises in strict mode when a file conversion fails" do
    a = write("docs/a.yml")
    bad = write("docs/bad.yml")

    allow(Yard::Yaml::Converter).to receive(:from_file) do |path, *_args|
      case path
      when a then {html: "<p>a</p>", title: "A", description: nil, meta: {}}
      when bad then raise Yard::Yaml::Error, "hard fail"
      else {html: "", title: File.basename(path), description: nil, meta: {}}
      end
    end

    cfg = Yard::Yaml::Config.new(include: [File.join(tmpdir, "docs/**/*.yml")], exclude: [], strict: true)
    expect { described_class.collect(cfg) }.to raise_error(Yard::Yaml::Error)
  end
end
