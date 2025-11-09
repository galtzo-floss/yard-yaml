# frozen_string_literal: true

RSpec.describe Yard::Yaml::Config do
  describe "::new" do
    it "sets conservative defaults" do
      cfg = described_class.new
      expect(cfg.include).to(eq(["docs/**/*.y{a,}ml", "*.y{a,}ml"]))
      expect(cfg.exclude).to(eq(["**/_*.y{a,}ml"]))
      expect(cfg.out_dir).to(eq("yaml"))
      expect(cfg.index).to(eq(true))
      expect(cfg.toc).to(eq("auto"))
      expect(cfg.converter_options).to(eq({}))
      expect(cfg.front_matter).to(eq(true))
      expect(cfg.strict).to(eq(false))
      expect(cfg.allow_erb).to(eq(false))
    end

    it "applies provided overrides" do
      cfg = described_class.new(
        include: ["x.yml"],
        exclude: [],
        out_dir: "x",
        index: false,
        toc: "none",
        converter_options: {pretty: true},
        front_matter: false,
        strict: true,
        allow_erb: true,
      )
      expect(cfg.include).to(eq(["x.yml"]))
      expect(cfg.exclude).to(eq([]))
      expect(cfg.out_dir).to(eq("x"))
      expect(cfg.index).to(eq(false))
      expect(cfg.toc).to(eq("none"))
      expect(cfg.converter_options).to(eq({pretty: true}))
      expect(cfg.front_matter).to(eq(false))
      expect(cfg.strict).to(eq(true))
      expect(cfg.allow_erb).to(eq(true))
    end
  end

  describe "#apply" do
    it "ignores unknown keys (Phase 0)" do
      cfg = described_class.new
      cfg.apply(foo: :bar, baz: 1)
      expect(cfg.include).to(eq(described_class::DEFAULT_INCLUDE))
      expect(cfg.out_dir).to(eq(described_class::DEFAULT_OUT_DIR))
    end

    it "coerces booleans and arrays" do
      cfg = described_class.new
      cfg.apply(index: 0, front_matter: nil, strict: "yes", include: "a.yml")
      expect(cfg.index).to(eq(false))
      expect(cfg.front_matter).to(eq(false))
      expect(cfg.strict).to(eq(true))
      expect(cfg.include).to(eq(["a.yml"]))
    end
  end
end
