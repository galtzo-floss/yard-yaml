# frozen_string_literal: true

require_relative "yaml/version"
require_relative "yaml/config"
require_relative "yaml/plugin"

module Yard
  module Yaml
    class Error < StandardError; end
  end
end
