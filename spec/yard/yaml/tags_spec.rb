# frozen_string_literal: true

RSpec.describe Yard::Yaml::Tags do
  it "registers @yaml and @yaml_file tags when YARD is available" do
    # Define a stub YARD tag library for registration
    calls = []
    library = Module.new
    library.define_singleton_method(:calls) { calls }
    library.define_singleton_method(:define_tag) { |*args| calls << args }

    stub_const("YARD", Module.new)
    stub_const("YARD::Tags", Module.new)
    stub_const("YARD::Tags::Library", library)

    described_class.register!
    calls = YARD::Tags::Library.calls
    expect(calls).to(be_a(Array))
    names = calls.map { |args| args[1] }
    expect(names).to(include(:yaml))
    expect(names).to(include(:yaml_file))
  end

  it "attaches an existing top-level Library shim when YARD has none" do
    stub_const("YARD", Module.new)
    stub_const("YARD::Tags", Module.new)

    library = Module.new do
      calls = []
      define_singleton_method(:calls) { calls }
      define_singleton_method(:define_tag) { |*args| calls << args }
    end

    stub_const("Library", library)

    described_class.register!

    expect(YARD::Tags::Library).to(be(library))
    expect(library.calls.map { |args| args[1] }).to(include(:yaml, :yaml_file))
  end

  it "creates a minimal tag library shim when YARD has none" do
    stub_const("YARD", Module.new)
    stub_const("YARD::Tags", Module.new)
    hide_const("Library") if Object.const_defined?(:Library)

    described_class.register!

    expect(YARD::Tags::Library.calls.map { |args| args[1] }).to(include(:yaml, :yaml_file))
  end
end
