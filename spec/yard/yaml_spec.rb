# frozen_string_literal: true

RSpec.describe Yard::Yaml do
  it "has a version number" do
    expect(Yard::Yaml::VERSION).not_to be_nil
  end

  it "logs errors through YARD logger when available" do
    stub_const("YARD", Module.new) unless defined?(YARD)
    stub_const(
      "YARD::Logger",
      Class.new do
        def error(_message)
        end
      end
    )
    logger = instance_double(YARD::Logger, error: nil)
    allow(YARD::Logger).to receive(:instance).and_return(logger)

    described_class.error("boom")

    expect(logger).to have_received(:error).with("yard-yaml: boom")
  end

  it "falls back to kernel warnings when YARD error logging fails", :check_output do
    stub_const("YARD", Module.new) unless defined?(YARD)
    stub_const(
      "YARD::Logger",
      Class.new do
        def error(_message)
        end
      end
    )
    logger = instance_double(YARD::Logger)
    allow(logger).to receive(:error).and_raise(StandardError, "logger unavailable")
    allow(YARD::Logger).to receive(:instance).and_return(logger)

    output = capture(:stderr) { described_class.error("boom") }

    expect(output).to include("yard-yaml: ERROR: boom")
  end

  it "falls back to kernel warnings when YARD warning logging fails", :check_output do
    stub_const("YARD", Module.new) unless defined?(YARD)
    stub_const(
      "YARD::Logger",
      Class.new do
        def warn(_message)
        end
      end
    )
    logger = instance_double(YARD::Logger)
    allow(logger).to receive(:warn).and_raise(StandardError, "logger unavailable")
    allow(YARD::Logger).to receive(:instance).and_return(logger)

    output = capture(:stderr) { described_class.warn("heads up") }

    expect(output).to include("yard-yaml: heads up")
  end

  it "mirrors config and pages to the YARD registry store when available" do
    stub_const("YARD", Module.new) unless defined?(YARD)
    stub_const("YARD::Registry", Class.new)
    store = {}
    allow(YARD::Registry).to receive(:store).and_return(store)

    config = described_class.configure(strict: true)
    pages = described_class.__set_pages__([{path: "data.yml"}])

    expect(store[:yard_yaml_config]).to equal(config)
    expect(store[:yard_yaml_pages]).to eq(pages)
  end
end
