require "spec_helper"

module Decidim
  describe FeatureConfiguration do
    subject { described_class.new }

    describe "attribute" do
      it "adds an attribute to the attribute hash with defaults" do
        subject.attribute :something
        expect(subject.attributes[:something].type).to eq(:boolean)
      end

      it "symbolizes the attribute's name"
    end
  end
end
