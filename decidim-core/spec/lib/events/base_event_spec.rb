require "spec_helper"

describe Decidim::Events::BaseEvent do
  describe ".types" do
    subject { described_class }

    it "returns an empty array" do
      expect(subject.types).to eq []
    end
  end
end
