# frozen_string_literal: true

# YARD default theme hook to insert inline-rendered YAML tags
# immediately after the main docstring in object pages.
#
# This file is only evaluated within YARD's rendering context. It has
# no side effects at require-time.

def init
  super
  sections.place(:yyaml_inline_after_docstring).after(:docstring)
end

def yyaml_inline_after_docstring
  erb(:inline_yaml)
end
