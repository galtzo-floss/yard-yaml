# frozen_string_literal: true

RSpec.describe Yard::Yaml::Emitter do
  describe ".slug_for" do
    it "uses meta.slug when provided" do
      page = {meta: {"slug" => "Custom-Slug_123"}, title: "Ignored", path: "/x/a.yml"}
      expect(described_class.slug_for(page)).to eq("custom-slug-123")
    end

    it "falls back to title when slug missing" do
      page = {meta: {}, title: "Hello World!", path: "/x/a.yml"}
      expect(described_class.slug_for(page)).to eq("hello-world")
    end

    it "falls back to filename when no slug or title" do
      page = {meta: {}, title: nil, path: "/x/Deep Dir/FiLe_Name.yaml"}
      expect(described_class.slug_for(page)).to eq("file-name")
    end

    it "sanitizes to alphanumerics and dashes" do
      page = {meta: {slug: " -- Weïrd ★ slug -- "}, title: nil, path: nil}
      expect(described_class.slug_for(page)).to eq("we-rd-slug")
    end
  end
end
