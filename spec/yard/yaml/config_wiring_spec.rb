# frozen_string_literal: true

RSpec.describe Yard::Yaml do
  describe "configuration defaults" do
    it "exposes defaults via .config" do
      cfg = described_class.config
      expect(cfg.include).to(eq(Yard::Yaml::Config::DEFAULT_INCLUDE))
      expect(cfg.exclude).to(eq(Yard::Yaml::Config::DEFAULT_EXCLUDE))
      expect(cfg.out_dir).to(eq(Yard::Yaml::Config::DEFAULT_OUT_DIR))
      expect(cfg.index).to(eq(Yard::Yaml::Config::DEFAULT_INDEX))
      expect(cfg.toc).to(eq(Yard::Yaml::Config::DEFAULT_TOC))
      expect(cfg.converter_options).to(eq(Yard::Yaml::Config::DEFAULT_CONVERTER_OPTIONS))
      expect(cfg.front_matter).to(eq(Yard::Yaml::Config::DEFAULT_FRONT_MATTER))
      expect(cfg.strict).to(eq(Yard::Yaml::Config::DEFAULT_STRICT))
      expect(cfg.allow_erb).to(eq(Yard::Yaml::Config::DEFAULT_ALLOW_ERB))
    end
  end

  describe Yard::Yaml::Cli do
    it "parses repeatable include and exclude flags" do
      argv = [
        "--yard_yaml-include", "docs/**/*.yml",
        "--yard_yaml-include", "*.yaml",
        "--yard_yaml-exclude", "**/_*.yml"
      ]
      overrides = described_class.parse(argv)
      expect(overrides[:include]).to(eq(["docs/**/*.yml", "*.yaml"]))
      expect(overrides[:exclude]).to(eq(["**/_*.yml"]))
    end

    it "parses boolean flags in both forms" do
      argv = [
        "--no-yard_yaml-index",
        "--yard_yaml-front_matter=false",
        "--yard_yaml-strict=true",
        "--yard_yaml-allow_erb",
      ]
      overrides = described_class.parse(argv)
      expect(overrides[:index]).to(eq(false))
      expect(overrides[:front_matter]).to(eq(false))
      expect(overrides[:strict]).to(eq(true))
      expect(overrides[:allow_erb]).to(eq(true))
    end

    it "parses converter_options as key:value pairs with scalar coercions" do
      argv = ["--yard_yaml-converter_options", "pretty:true,wrap:80,ratio:1.5,name:alpha"]
      overrides = described_class.parse(argv)
      expect(overrides[:converter_options]).to(eq({
        "pretty" => true,
        "wrap" => 80,
        "ratio" => 1.5,
        "name" => "alpha",
      }))
    end

    it "warns and ignores unknown flags", :check_output do
      argv = ["--yard_yaml-unknown", "x"]
      output = capture(:stderr) { described_class.parse(argv) }
      expect(output).to(include("yard-yaml: unknown flag --yard_yaml-unknown"))
    end

    it "warns on missing value for include/out_dir and converter_options", :check_output do
      argv = [
        "--yard_yaml-include",
        "--yard_yaml-out_dir",
        "--yard_yaml-converter_options"
      ]
      output = capture(:stderr) { described_class.parse(argv) }
      expect(output).to(include("missing value for --yard_yaml-include"))
      expect(output).to(include("missing value for --yard_yaml-out_dir"))
      expect(output).to(include("missing value for --yard_yaml-converter_options"))
    end

    it "warns on invalid boolean value and coerces to false", :check_output do
      argv = ["--yard_yaml-index=maybe"]
      output = capture(:stderr) { @ov = described_class.parse(argv) }
      expect(output).to(include("invalid boolean"))
      expect(@ov[:index]).to(eq(false))
    end

    it "warns on invalid converter option pair and ignores it", :check_output do
      argv = ["--yard_yaml-converter_options", "novalue"]
      output = capture(:stderr) { @ov = described_class.parse(argv) }
      expect(output).to(include("invalid converter option"))
      expect(@ov[:converter_options]).to(eq({}))
    end

    it "warns on equals-form unknown flag", :check_output do
      argv = ["--yard_yaml-foo=bar"]
      output = capture(:stderr) { described_class.parse(argv) }
      expect(output).to(include("unknown flag --yard_yaml-foo"))
    end
  end

  describe Yard::Yaml::Plugin do
    it "applies argv overrides when activated" do
      argv = [
        "--yard_yaml-include", "examples/**/*.yml",
        "--yard_yaml-index=false",
        "--yard_yaml-out_dir", "yaml_docs",
      ]
      expect { described_class.activate(argv) }.not_to(raise_error)
      cfg = Yard::Yaml.config
      expect(cfg.include).to(include("examples/**/*.yml"))
      expect(cfg.index).to(eq(false))
      expect(cfg.out_dir).to(eq("yaml_docs"))
    end

    it "allows programmatic overrides after activation to take precedence" do
      argv = ["--yard_yaml-index=true"]
      described_class.activate(argv)
      Yard::Yaml.configure(index: false)
      expect(Yard::Yaml.config.index).to(eq(false))
    end
  end
end
