# frozen_string_literal: true

RSpec.describe Yard::Yaml::Emitter do
  describe ".slug_for" do
    it "uses meta slug when present" do
      page = { title: "Ignored", meta: { slug: "My-Custom_Slug" } }
      expect(described_class.slug_for(page)).to(eq("my-custom-slug"))
    end

    it "derives from title when slug missing" do
      page = { title: "Hello, World!", meta: {} }
      expect(described_class.slug_for(page)).to(eq("hello-world"))
    end

    it "falls back to filename when title and slug missing" do
      page = { path: "/docs/Sample File.yaml", meta: {} }
      expect(described_class.slug_for(page)).to(eq("sample-file"))
    end

    it "falls back to generic when nothing available" do
      page = { meta: {} }
      expect(described_class.slug_for(page)).to(eq("page"))
    end
  end
end
