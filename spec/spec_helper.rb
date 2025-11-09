# frozen_string_literal: true

# Start coverage as early as possible for deterministic results
begin
  require "kettle-soup-cover"
  require "simplecov" if Kettle::Soup::Cover::DO_COV # `.simplecov` is run here!
rescue LoadError => error
  # check the error message, and re-raise if not what is expected
  raise error unless error.message.include?("kettle")
end

require "kettle/test/rspec"

# Library Configs
require_relative "config/debug"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Ensure global state from Yard::Yaml does not leak across examples
  config.after(:each) do
    if defined?(::Yard::Yaml) && ::Yard::Yaml.respond_to?(:__reset_state__)
      ::Yard::Yaml.__reset_state__
    end
  end
end

require "yard/yaml"
