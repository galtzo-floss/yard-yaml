# frozen_string_literal: true

RSpec.describe Yard::Yaml::Emitter do
  describe ".slug_for" do
    it "uses meta.slug when provided" do
      page = {meta: {"slug" => "Custom-Slug_123"}, title: "Ignored", path: "/x/a.yml"}
      expect(described_class.slug_for(page)).to eq("custom-slug-123")
    end

    it "falls back to path when slug missing" do
      page = {meta: {}, title: "Hello World!", path: "/x/a.yml"}
      expect(described_class.slug_for(page)).to eq("x-a")
    end

    it "uses the full relative path to reduce collisions" do
      page = {meta: {}, title: nil, path: "/x/Deep Dir/FiLe_Name.yaml"}
      expect(described_class.slug_for(page)).to eq("x-deep-dir-file-name")
    end

    it "falls back to title when no slug or path is present" do
      page = {meta: {}, title: "Hello World!", path: nil}
      expect(described_class.slug_for(page)).to eq("hello-world")
    end

    it "sanitizes to alphanumerics and dashes" do
      page = {meta: {slug: " -- Weïrd ★ slug -- "}, title: nil, path: nil}
      expect(described_class.slug_for(page)).to eq("we-rd-slug")
    end
  end
end
