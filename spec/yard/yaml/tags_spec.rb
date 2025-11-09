# frozen_string_literal: true

RSpec.describe Yard::Yaml::Tags do
  before do
    # Define a stub YARD tag library for registration
    stub = Module.new do
      module Library
        class << self
          attr_accessor :calls
          def define_tag(*args)
            self.calls ||= []
            self.calls << args
          end
        end
      end
    end

    Object.send(:remove_const, :YARD) if defined?(::YARD)
    Object.const_set(:YARD, Module.new)
    ::YARD.const_set(:Tags, stub)
  end

  it "registers @yaml and @yaml_file tags when YARD is available" do
    described_class.register!
    calls = ::YARD::Tags::Library.calls
    expect(calls).to(be_a(Array))
    names = calls.map { |args| args[1] }
    expect(names).to(include(:yaml))
    expect(names).to(include(:yaml_file))
  end
end
