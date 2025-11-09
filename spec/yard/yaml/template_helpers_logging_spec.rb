# frozen_string_literal: true

require "securerandom"

RSpec.describe Yard::Yaml::TemplateHelpers do
  describe ".render_yaml_file" do
    it "warns and returns empty string when file missing in non-strict mode", :check_output do
      Yard::Yaml.configure(strict: false)
      html = described_class.render_yaml_file("/definitely/not/found-#{SecureRandom.hex}.yml")
      expect(html).to eq("")
    end

    it "raises Yard::Yaml::Error when file missing in strict mode" do
      Yard::Yaml.configure(strict: true)
      expect {
        described_class.render_yaml_file("/definitely/not/found-#{SecureRandom.hex}.yml")
      }.to raise_error(Yard::Yaml::Error)
    end

    it "propagates converter errors according to strict toggle" do
      path = File.join(Dir.pwd, "tmp", "yyaml_tpl_log_spec.yml")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "a: 1\n")

      # Non-strict: converter raises -> helper returns "" and warns
      Yard::Yaml.configure(strict: false)
      allow(Yard::Yaml::Converter).to receive(:from_file).and_raise(StandardError, "boom")
      output = capture(:stderr) do
        expect(described_class.render_yaml_file(path)).to eq("")
      end
      expect(output).to include("yard-yaml:")

      # Strict: converter raises -> helper raises Yard::Yaml::Error
      Yard::Yaml.configure(strict: true)
      allow(Yard::Yaml::Converter).to receive(:from_file).and_raise(Yard::Yaml::Error, "hard")
      expect { described_class.render_yaml_file(path) }.to raise_error(Yard::Yaml::Error)
    ensure
      FileUtils.rm_f(path)
    end
  end
end
