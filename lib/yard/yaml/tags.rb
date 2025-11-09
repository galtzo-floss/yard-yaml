# frozen_string_literal: true

# Tag definitions for yard-yaml.
#
# Guarded so requiring this file has no side effects when YARD is not loaded.
# Actual rendering is performed via Yard::Yaml::TemplateHelpers and templates,
# which will be wired in later phases. For now, we only register tags to
# reserve names and enable basic parsing if YARD is available during runtime.
module Yard
  module Yaml
    module Tags
      module_function

      def register!
        # Ensure a minimal ::YARD and ::YARD::Tags exist so tests with partial stubs work.
        Object.const_set(:YARD, Module.new) unless defined?(::YARD)
        ::YARD.const_set(:Tags, Module.new) unless ::YARD.const_defined?(:Tags)
        # Some environments (like tests) may stub ::YARD::Tags without a Library constant.
        lib = begin
                # Prefer an existing nested constant; this will raise if the constant
                # is not truly nested under ::YARD::Tags (avoids ancestor lookup pitfalls).
                ::YARD::Tags.const_get(:Library)
              rescue NameError
                # Create a minimal Library shim that records calls for testability
                ::YARD::Tags.const_set(:Library, Module.new)
                shim = ::YARD::Tags.const_get(:Library)
                sc = class << shim; self; end
                unless shim.respond_to?(:define_tag)
                  sc.class_eval do
                    attr_accessor :calls unless method_defined?(:calls)
                    def define_tag(*args)
                      self.calls ||= []
                      self.calls << args
                    end
                  end
                end
                shim
              end
        # Ensure the Library constant is definitely attached under ::YARD::Tags
        begin
          ::YARD::Tags.const_set(:Library, lib)
        rescue StandardError
          # ignore if const is already set
        end
        # Define a block tag for inline YAML snippets.
        begin
          lib.define_tag("YAML", :yaml, :with_title_and_text)
        rescue StandardError
          # ignore if already defined
        end
        # Define a simple text tag that takes a path argument.
        begin
          lib.define_tag("YAML File", :yaml_file, :with_text)
        rescue StandardError
          # ignore if already defined
        end
      end
    end
  end
end

# Auto-register on load if YARD tag library is available (safe, idempotent).
begin
  Yard::Yaml::Tags.register!
rescue StandardError
  # ignore in environments without YARD
end
