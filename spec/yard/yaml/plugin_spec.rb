# frozen_string_literal: true

RSpec.describe Yard::Yaml::Plugin do
  it "is not activated by default" do
    expect(described_class.activated?).to(be(false))
  end

  it "can be activated explicitly without side effects" do
    expect { described_class.activate }.not_to(raise_error)
    expect(described_class.activated?).to(be(true))
  end
end
