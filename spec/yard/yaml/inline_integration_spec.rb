# frozen_string_literal: true

RSpec.describe "Inline ERB integration for yard-yaml" do
  let(:erb_path) { File.join(Dir.pwd, "templates", "yard_yaml", "_inline_yaml.erb") }

  before do
    # Provide a deterministic backend for converter via TemplateHelpers calls
    backend = Class.new do
      class << self
        def convert(yaml, options)
          {html: "<pre>#{yaml.strip}</pre>", title: options[:title], description: nil, meta: {}}
        end
      end
    end
    Yard::Yaml::Converter.backend = backend
  end

  it "renders @yaml and @yaml_file inline using TagRenderer via the ERB partial" do
    skip("inline partial not found") unless File.exist?(erb_path)

    # Fake object with tags(:yaml) and tags(:yaml_file)
    tag = Struct.new(:text)
    obj = Class.new do
      def initialize(yaml_blocks: [], yaml_files: [])
        @yaml_blocks = yaml_blocks
        @yaml_files = yaml_files
      end

      def tags(name)
        case name
        when :yaml then @yaml_blocks
        when :yaml_file then @yaml_files
        else []
        end
      end
    end

    o = obj.new(
      yaml_blocks: [tag.new("a: 1\n")],
      yaml_files:  [tag.new("#{__FILE__}")],
    )

    # Render ERB with a local variable `object`
    object = o
    tpl = ERB.new(File.read(erb_path))
    html = tpl.result(binding)
    expect(html).to include("yyaml-inline").or include("yyaml-file")
    expect(html).to include("<pre>a: 1</pre>")
  end

  it "honors strict mode via helpers for missing files (warns when non-strict)", :check_output do
    skip("inline partial not found") unless File.exist?(erb_path)
    tag = Struct.new(:text)
    obj = Class.new do
      def initialize(files)
        @files = files
      end

      def tags(name)
        (name == :yaml_file) ? @files : []
      end
    end

    Yard::Yaml.configure(strict: false)
    object = obj.new([tag.new("/no/such.yml")])
    tpl = ERB.new(File.read(erb_path))
    output = capture(:stderr) { @html = tpl.result(binding) }
    expect(@html).to be_a(String)
    expect(output).to include("yard-yaml:")
  end
end
