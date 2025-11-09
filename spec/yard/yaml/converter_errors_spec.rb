# frozen_string_literal: true

require "securerandom"

RSpec.describe Yard::Yaml::Converter do
  let(:raising_backend) do
    Class.new do
      class << self
        def convert(_yaml, _options)
          raise StandardError, "boom"
        end
      end
    end
  end

  describe "error handling paths" do
    it "warns and returns empty result when backend.convert raises (non-strict)", :check_output do
      described_class.backend = raising_backend
      Yard::Yaml.configure(strict: false)
      output = capture(:stderr) {
        res = described_class.from_string("a: 1")
        expect(res[:html]).to eq("")
        expect(res[:meta]).to eq({})
      }
      expect(output).to include("yard-yaml:")
    end

    it "raises Yard::Yaml::Error when strict and backend.convert raises" do
      described_class.backend = raising_backend
      Yard::Yaml.configure(strict: true)
      expect {
        described_class.from_string("a: 1")
      }.to raise_error(Yard::Yaml::Error)
    end

    it "warns and returns empty result when backend is missing (non-strict)", :check_output do
      # Simulate missing backend by forcing .backend to return nil
      described_class.backend = nil
      allow(described_class).to receive(:backend).and_return(nil)
      Yard::Yaml.configure(strict: false)
      output = capture(:stderr) do
        res = described_class.from_string("a: 1")
        expect(res[:html]).to eq("")
        expect(res[:meta]).to eq({})
      end
      expect(output).to include("yard-yaml:")
      expect(output).to include("backend")
    end

    it "raises Yard::Yaml::Error when backend is missing and strict" do
      described_class.backend = nil
      allow(described_class).to receive(:backend).and_return(nil)
      Yard::Yaml.configure(strict: true)
      expect {
        described_class.from_string("a: 1")
      }.to raise_error(Yard::Yaml::Error)
    end

    it "warns and returns empty result when from_file path is missing in non-strict", :check_output do
      Yard::Yaml.configure(strict: false)
      output = capture(:stderr) do
        res = described_class.from_file("/no/such/#{SecureRandom.hex}.yml")
        expect(res[:html]).to eq("")
        expect(res[:meta]).to eq({})
      end
      expect(output).to include("yard-yaml:")
      expect(output).to include("missing file")
    end

    it "raises Yard::Yaml::Error when from_file path is missing and strict" do
      Yard::Yaml.configure(strict: true)
      expect {
        described_class.from_file("/no/such/#{SecureRandom.hex}.yml")
      }.to raise_error(Yard::Yaml::Error)
    end
  end
end
