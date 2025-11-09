# frozen_string_literal: true

# YARD default layout hook to append a "YAML Docs" sidebar section
# listing discovered YAML pages. This only runs inside YARD's rendering
# context and has no side effects at require-time.

def init
  super
  @sidebar_sections ||= []
  @sidebar_sections << :yyaml_docs_sidebar
end

def yyaml_docs_sidebar
  erb(:sidebar_yaml_docs)
end
