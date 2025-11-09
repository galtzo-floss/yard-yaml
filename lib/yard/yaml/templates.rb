# frozen_string_literal: true

# Template path registration for yard-yaml.
#
# Phase 5 (part 1): register a templates directory so future template
# overrides/partials can be discovered by YARD. Actual inline placement and
# navigation hooks will follow in the next step to keep require-time behavior
# inert and tests deterministic.
#
# This file is safe to require in environments without YARD present; it checks
# for YARD constants before attempting any registration.
module Yard
  module Yaml
    module Templates
      module_function

      # Register the templates path with YARD if available.
      # Idempotent and safe when YARD is not loaded.
      def register!
        return unless defined?(::YARD) && ::YARD.const_defined?(:Templates)
        base = File.expand_path("../../../templates", __dir__)
        begin
          ::YARD::Templates::Engine.register_template_path(base)
        rescue StandardError
          # ignore if engine not available or already registered
        end
      end
    end
  end
end

# Try to register immediately if YARD is present; otherwise remain inert.
begin
  Yard::Yaml::Templates.register!
rescue StandardError
  # ignore in non-YARD contexts
end
