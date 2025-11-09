# frozen_string_literal: true

RSpec.describe Yard::Yaml::Emitter do
  let(:tmpdir) { Dir.mktmpdir("yyaml-out-") }

  after do
    FileUtils.remove_entry(tmpdir) if tmpdir && Dir.exist?(tmpdir)
  end

  let(:pages) do
    [
      { path: "/docs/a.yml", html: "<p>A</p>", title: "Alpha", description: "First", meta: {} },
      { path: "/docs/b.yaml", html: "<p>B</p>", title: "Beta", description: nil, meta: { "slug" => "custom-b" } },
    ]
  end

  it "emits per-page files and an index when enabled" do
    cfg = Yard::Yaml::Config.new(out_dir: "yaml", index: true)
    written = described_class.emit!(pages: pages, output_dir: tmpdir, config: cfg)
    expect(written).to(include(File.join(tmpdir, "yaml", "alpha.html")))
    expect(written).to(include(File.join(tmpdir, "yaml", "custom-b.html")))
    expect(written).to(include(File.join(tmpdir, "yaml", "index.html")))

    html_a = File.read(File.join(tmpdir, "yaml", "alpha.html"))
    expect(html_a).to(include("<h1 class=\"yyaml-title\">Alpha</h1>"))
    expect(html_a).to(include("<div class=\"yyaml-body\"><p>A</p></div>"))

    html_idx = File.read(File.join(tmpdir, "yaml", "index.html"))
    expect(html_idx).to(include("YAML Documents"))
    expect(html_idx).to(include("alpha.html"))
    expect(html_idx).to(include("custom-b.html"))
  end

  it "does not write index when disabled" do
    cfg = Yard::Yaml::Config.new(out_dir: "yaml_docs", index: false)
    written = described_class.emit!(pages: pages, output_dir: tmpdir, config: cfg)
    expect(written).not_to(include(File.join(tmpdir, "yaml_docs", "index.html")))
    expect(File).not_to(exist(File.join(tmpdir, "yaml_docs", "index.html")))
  end

  it "derives slug from title or path when missing" do
    cfg = Yard::Yaml::Config.new
    pgs = [ { path: "/x/y/z.yml", html: "<p>Z</p>", title: nil, description: nil, meta: {} } ]
    described_class.emit!(pages: pgs, output_dir: tmpdir, config: cfg)
    expect(File).to(exist(File.join(tmpdir, cfg.out_dir, "z.html")))
  end
end
