# frozen_string_literal: true

RSpec.describe Yard::Yaml::Discovery do
  let(:tmpdir) { File.join(Dir.pwd, "tmp", "yyaml_discovery_ordering_spec") }

  before do
    FileUtils.mkdir_p(tmpdir)
  end

  after do
    FileUtils.rm_rf(tmpdir)
  end

  def write(path, content)
    full = File.join(tmpdir, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
    full
  end

  it "orders by numeric nav_order (Integer > Float > Infinity for non-numeric), then title, then path" do
    a = write("docs/a.yml", "---\ntitle: Zeta\nnav_order: 10\n---\nkey: v\n")
    b = write("docs/b.yml", "---\ntitle: Alpha\nnav_order: 2.5\n---\nkey: v\n")
    c = write("docs/c.yml", "---\ntitle: bravo\nnav_order: 'not-a-number'\n---\nkey: v\n")

    allow(Yard::Yaml::Converter).to receive(:from_file) do |path, _opts, config:|
      title = case path
      when a then "Zeta"
      when b then "Alpha"
      when c then "bravo"
      end
      meta = case path
      when a then {"nav_order" => 10}
      when b then {"nav_order" => 2.5}
      when c then {"nav_order" => "not-a-number"}
      end
      {html: "<p>ok</p>", title: title, description: nil, meta: meta}
    end

    cfg = Yard::Yaml::Config.new(include: [File.join(tmpdir, "docs/**/*.yml")], exclude: [])
    pages = described_class.collect(cfg)
    # Expect ordering: b (2.5) first, then a (10), then c (Infinity, non-numeric) last
    expect(pages.map { |p| p[:title] }).to eq(["Alpha", "Zeta", "bravo"])
  end

  it "treats string numerics as numbers and sorts before non-numeric" do
    s1 = write("docs/s1.yml", "---\ntitle: One\nnav_order: '1'\n---\n")
    s2 = write("docs/s2.yml", "---\ntitle: Two\nnav_order: '2.1'\n---\n")
    sN = write("docs/sN.yml", "---\ntitle: Enn\nnav_order: 'n/a'\n---\n")

    allow(Yard::Yaml::Converter).to receive(:from_file) do |path, _opts, **|
      case path
      when s1 then {html: "", title: "One", description: nil, meta: {"nav_order" => "1"}}
      when s2 then {html: "", title: "Two", description: nil, meta: {"nav_order" => "2.1"}}
      when sN then {html: "", title: "Enn", description: nil, meta: {"nav_order" => "n/a"}}
      else {html: "", title: File.basename(path), description: nil, meta: {}}
      end
    end

    Dir.chdir(tmpdir) do
      cfg = Yard::Yaml::Config.new(include: ["docs/**/*.yml"], exclude: [])
      pages = described_class.collect(cfg)
      expect(pages.map { |p| p[:title] }).to eq(["One", "Two", "Enn"]) # numeric first
    end
  end
end
