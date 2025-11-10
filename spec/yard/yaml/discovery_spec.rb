# frozen_string_literal: true

RSpec.describe Yard::Yaml::Discovery do
  let(:tmpdir) { File.join(Dir.pwd, "tmp", "yyaml_discovery_spec") }

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

  describe ".find_files" do
    it "matches include globs and applies exclude globs" do
      a = write("docs/a.yml", "x: 1\n")
      b = write("docs/a.yaml", "x: 2\n")
      _c = write("docs/_hidden.yml", "x: 3\n")
      _d = write("docs/sub/_skip.yaml", "x: 4\n")
      e = write("root.yml", "x: 5\n")

      Dir.chdir(tmpdir) do
        include_globs = ["docs/**/*.y{a,}ml", "*.y{a,}ml"]
        exclude_globs = ["**/_*.y{a,}ml"]
        files = described_class.find_files(include_globs, exclude_globs)
        expect(files).to(include(a, b, e))
        expect(files.grep(/_hidden/)).to(be_empty)
        expect(files.grep(/_skip/)).to(be_empty)
      end
    end
  end

  describe ".collect" do
    it "converts discovered files and returns normalized pages" do
      write("docs/one.yml", "title: One\n---\nkey: v\n")
      write("docs/two.yaml", "title: Two\n---\nkey: v\n")

      Dir.chdir(tmpdir) do
        cfg = Yard::Yaml::Config.new(
          include: ["docs/**/*.y{a,}ml"],
          exclude: [],
        )

        allow(Yard::Yaml::Converter).to(receive(:from_file)) do |path, _opts, config:|
          {
            html: "<p>#{File.basename(path)}</p>",
            title: File.basename(path, ".yml").sub(/\.yaml\z/, ""),
            description: nil,
            meta: {"source" => path, "strict" => config.strict},
          }
        end

        pages = described_class.collect(cfg)
        expect(pages.size).to(eq(2))
        names = pages.map { |h| h[:title] }
        expect(names).to(contain_exactly("one", "two"))
        expect(pages.first).to(include(:path, :html, :title, :description, :meta))
      end
    end

    it "includes .cff files by default (CITATION.cff is YAML)" do
      write("docs/citation.cff", "title: Cite\n---\nkey: v\n")

      Dir.chdir(tmpdir) do
        cfg = Yard::Yaml::Config.new
        allow(Yard::Yaml::Converter).to(receive(:from_file)) do |path, _opts, config:|
          {
            html: "<p>#{File.basename(path)}</p>",
            title: File.basename(path, File.extname(path)),
            description: nil,
            meta: {"source" => path, "strict" => config.strict},
          }
        end

        pages = described_class.collect(cfg)
        titles = pages.map { |p| p[:title] }
        expect(titles).to(include("citation"))
      end
    end
  end

  describe "integration via Plugin.activate" do
    it "sets Yard::Yaml.pages after activation" do
      _p1 = write("docs/act.yml", "x: 1\n")

      Dir.chdir(tmpdir) do
        allow(Yard::Yaml::Converter).to(receive(:from_file)).and_return({html: "<p>ok</p>", title: "act", description: nil, meta: {}})
        expect(Yard::Yaml.pages).to(be_nil)
        Yard::Yaml::Plugin.activate(["--yard_yaml-include", "docs/**/*.y{a,}ml", "--yard_yaml-exclude", "**/_*.y{a,}ml"])
        pages = Yard::Yaml.pages
        expect(pages).to(be_an(Array))
        expect(pages.first).to(include(title: "act"))
      end
    end
  end
end
