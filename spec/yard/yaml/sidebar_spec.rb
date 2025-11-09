# frozen_string_literal: true

RSpec.describe "Sidebar YAML Docs partial" do
  let(:erb_path) { File.join(Dir.pwd, "templates", "yard_yaml", "_sidebar_yaml_docs.erb") }

  before do
    skip("sidebar partial not found") unless File.exist?(erb_path)
  end

  it "lists pages with links using emitter slugs" do
    pages = [
      { path: "/x/a.yml", html: "<p>a</p>", title: "Alpha", description: nil, meta: {} },
      { path: "/x/b.yaml", html: "<p>b</p>", title: nil, description: nil, meta: { "slug" => "bravo" } }
    ]
    Yard::Yaml.__set_pages__(pages)
    Yard::Yaml.configure(out_dir: "yaml")

    tpl = ERB.new(File.read(erb_path))
    html = tpl.result(binding)
    expect(html).to(include('/yaml/alpha.html'))
    expect(html).to(include('/yaml/bravo.html'))
  end
end
