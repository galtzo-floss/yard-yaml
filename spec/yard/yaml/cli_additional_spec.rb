# frozen_string_literal: true

RSpec.describe Yard::Yaml::Cli do
  describe ".parse additional booleans" do
    it "treats bare presence as true for boolean flags" do
      argv = [
        "--yard_yaml-index",
        "--yard_yaml-front_matter",
        "--yard_yaml-strict",
        "--yard_yaml-allow_erb",
      ]
      ov = described_class.parse(argv)
      expect(ov[:index]).to eq(true)
      expect(ov[:front_matter]).to eq(true)
      expect(ov[:strict]).to eq(true)
      expect(ov[:allow_erb]).to eq(true)
    end

    it "parses equals-form booleans with mixed case" do
      argv = [
        "--yard_yaml-index=TRUE",
        "--yard_yaml-front_matter=No",
        "--yard_yaml-strict=On",
        "--yard_yaml-allow_erb=off",
      ]
      ov = described_class.parse(argv)
      expect(ov[:index]).to eq(true)
      expect(ov[:front_matter]).to eq(false)
      expect(ov[:strict]).to eq(true)
      expect(ov[:allow_erb]).to eq(false)
    end
  end
end
