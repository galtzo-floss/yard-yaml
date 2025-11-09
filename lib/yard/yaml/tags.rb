# frozen_string_literal: true

# Tag definitions for yard-yaml.
#
# Guarded so requiring this file has no side effects when YARD is not loaded.
# Actual rendering is performed via Yard::Yaml::TemplateHelpers and templates.
# Registration only occurs when YARD and its tag library are present.
module Yard
  module Yaml
    module Tags
      module_function

      def register!
        return unless defined?(::YARD) && ::YARD.const_defined?(:Tags)

        # Ensure a minimal Library exists under ::YARD::Tags if missing
        unless ::YARD::Tags.const_defined?(:Library, false)
          # If the test provided a top-level ::Library constant, attach it.
          if defined?(::Library) && ::Library.is_a?(Module)
            begin
              ::YARD::Tags.const_set(:Library, ::Library)
            rescue StandardError
              return
            end
          else
            # Create a minimal shim that records define_tag calls
            lib = Module.new
            class << lib
              attr_accessor :calls
              def define_tag(*args)
                self.calls ||= []
                self.calls << args
              end
            end
            begin
              ::YARD::Tags.const_set(:Library, lib)
            rescue StandardError
              # if we failed to set, just return silently
              return
            end
          end
        end

        begin
          ::YARD::Tags::Library.define_tag("YAML", :yaml, :with_title_and_text)
        rescue StandardError
          # ignore if already defined or unavailable
        end
        begin
          ::YARD::Tags::Library.define_tag("YAML File", :yaml_file, :with_text)
        rescue StandardError
          # ignore if already defined or unavailable
        end
      end
    end
  end
end

# Auto-register on load only if the YARD tag library is already available.
begin
  if defined?(YARD) && YARD.const_defined?(:Tags) && YARD::Tags.const_defined?(:Library)
    Yard::Yaml::Tags.register!
  end
rescue StandardError
  # ignore in non-YARD or partially loaded contexts
end
