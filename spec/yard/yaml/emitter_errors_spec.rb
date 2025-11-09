# frozen_string_literal: true

RSpec.describe Yard::Yaml::Emitter do
  let(:tmpdir) { Dir.mktmpdir("yyaml-out-err-") }
  let(:pages) do
    [{path: "/docs/a.yml", html: "<p>A</p>", title: "Alpha", description: nil, meta: {}}]
  end

  after { FileUtils.remove_entry(tmpdir) if tmpdir && Dir.exist?(tmpdir) }

  it "warns when a write fails (non-strict)", :check_output do
    cfg = Yard::Yaml::Config.new(out_dir: "yaml", index: true, strict: false)
    # Stub FileUtils.mv to raise for the first call to simulate a write error
    allow(FileUtils).to receive(:mv).and_raise(StandardError.new("disk full"))
    output = capture(:stderr) do
      described_class.emit!(pages: pages, output_dir: tmpdir, config: cfg)
    end
    expect(output).to include("yard-yaml: write failed")
  end

  it "raises Yard::Yaml::Error when strict and a write fails" do
    cfg = Yard::Yaml::Config.new(out_dir: "yaml", index: true, strict: true)
    allow(FileUtils).to receive(:mv).and_raise(StandardError.new("disk full"))
    expect {
      described_class.emit!(pages: pages, output_dir: tmpdir, config: cfg)
    }.to raise_error(Yard::Yaml::Error, /write failed/)
  end
end
