# frozen_string_literal: true

# YARD plugin loader for `--plugin yaml`.
# YARD tries requiring several patterns; providing `yard-yaml` ensures
# it can be loaded regardless of whether YARD attempts `yard-yaml` or `yard/yaml`.
require_relative "yard/yaml"
require "version_gem"
require_relative "yard/yaml/version"

Yard::Yaml::Plugin.activate(ARGV)
Yard::Yaml::Plugin.install_at_exit(ARGV)

Yard::Yaml::Version.class_eval do
  extend VersionGem::Basic
end
