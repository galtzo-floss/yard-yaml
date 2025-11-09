# frozen_string_literal: true

# YARD plugin loader for `--plugin yaml`.
# YARD tries requiring several patterns; providing `yard-yaml` ensures
# it can be loaded regardless of whether YARD attempts `yard-yaml` or `yard/yaml`.
require_relative "yard/yaml"
