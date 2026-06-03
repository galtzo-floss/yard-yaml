# frozen_string_literal: true

RSpec.describe Yard::Yaml::Plugin do
  it "is not activated by default" do
    expect(described_class.activated?).to(be(false))
  end

  it "can be activated explicitly without side effects" do
    expect { described_class.activate }.not_to(raise_error)
    expect(described_class.activated?).to(be(true))
  end

  it "resolves YARD output from argv" do
    expect(described_class.yard_output_dir(["--output", "docs"])).to eq("docs")
    expect(described_class.yard_output_dir(["--output=site"])).to eq("site")
    expect(described_class.yard_output_dir(["-o", "api"])).to eq("api")
  end

  it "resolves YARD output from .yardopts and falls back to doc" do
    allow(File).to receive(:file?).with(".yardopts").and_return(false)
    expect(described_class.yard_output_dir([])).to eq("doc")

    allow(File).to receive(:file?).with(".yardopts").and_return(true)
    allow(File).to receive(:read).with(".yardopts").and_return("--markup markdown --output docs\n")
    expect(described_class.yard_output_dir([])).to eq("docs")
  end

  it "ignores unreadable .yardopts content when resolving output" do
    allow(File).to receive(:file?).with(".yardopts").and_return(true)
    allow(File).to receive(:read).with(".yardopts").and_return(%("--output "unterminated\n))

    expect(described_class.yard_output_dir([])).to eq("doc")
  end

  it "installs the at-exit emitter only once" do
    installed = []
    allow(described_class).to receive(:at_exit) { |&block| installed << block }

    described_class.install_at_exit(["--output", "docs"])
    described_class.install_at_exit(["--output", "ignored"])

    expect(installed.size).to eq(1)
  end

  it "returns no emitted files when no pages were collected" do
    expect(described_class.emit!(output_dir: "docs")).to be_empty
  end

  it "emits collected pages to the YARD output directory" do
    tmp_root = File.expand_path("../../tmp", __dir__)
    FileUtils.mkdir_p(tmp_root)
    Dir.mktmpdir("yard-yaml-plugin", tmp_root) do |tmpdir|
      Yard::Yaml.__set_pages__([{path: "CITATION.cff", html: "<p>ok</p>", title: "Citation", description: nil, meta: {}}])
      written = described_class.emit!(output_dir: tmpdir)

      expect(written).to include(File.join(tmpdir, "yaml", "citation.html"))
      expect(File.read(File.join(tmpdir, "yaml", "citation.html"))).to include("<p>ok</p>")
    end
  end
end
