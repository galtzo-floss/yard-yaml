# frozen_string_literal: true

module Yard
  module Yaml
    module Version
      VERSION = "0.1.0"
    end
    VERSION = Version::VERSION # Support the traditional VERSION constant.
  end
end
