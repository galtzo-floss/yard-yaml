# frozen_string_literal: true

RSpec.describe Yard::Yaml::Tags do
  before do
    # Define a stub YARD tag library for registration
    calls = []
    library = Module.new
    library.define_singleton_method(:calls) { calls }
    library.define_singleton_method(:define_tag) { |*args| calls << args }

    stub_const("YARD", Module.new)
    stub_const("YARD::Tags", Module.new)
    stub_const("YARD::Tags::Library", library)
  end

  it "registers @yaml and @yaml_file tags when YARD is available" do
    described_class.register!
    calls = YARD::Tags::Library.calls
    expect(calls).to(be_a(Array))
    names = calls.map { |args| args[1] }
    expect(names).to(include(:yaml))
    expect(names).to(include(:yaml_file))
  end
end
