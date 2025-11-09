# frozen_string_literal: true

module Yard
  module Yaml
    # Plugin activation scaffold for yard-yaml.
    #
    # Phase 0: This module intentionally performs no registration on load.
    # In later phases, #activate will register tags, templates, and hooks with YARD.
    module Plugin
      @activated = false

      class << self
        # Whether the plugin has been activated for the current process.
        # Activation is explicit; requiring this file does not activate anything.
        #
        # @return [Boolean]
        def activated?
          @activated
        end

        # Activate the plugin (placeholder; no side effects in Phase 0).
        # Later phases will register template paths, tags, and hooks here.
        #
        # @return [void]
        def activate
          @activated = true
          nil
        end
      end
    end
  end
end
