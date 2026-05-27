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

  it "emits collected pages to the YARD output directory" do
    tmpdir = Dir.mktmpdir("yyaml-plugin-emit")
    begin
      Yard::Yaml.__set_pages__([{path: "CITATION.cff", html: "<p>ok</p>", title: "Citation", description: nil, meta: {}}])
      written = described_class.emit!(output_dir: tmpdir)

      expect(written).to include(File.join(tmpdir, "yaml", "citation.html"))
      expect(File.read(File.join(tmpdir, "yaml", "citation.html"))).to include("<p>ok</p>")
    ensure
      FileUtils.rm_rf(tmpdir)
    end
  end
end
