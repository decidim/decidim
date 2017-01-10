require "spec_helper"

module Decidim
  describe FeatureConfiguration do
    subject { described_class.new }

    describe "attribute" do
      it "adds an attribute to the attribute hash with defaults" do
        subject.attribute :something
        expect(subject.attributes[:something].type).to eq(:boolean)
      end

      it "symbolizes the attribute's name" do
        subject.attribute "something"
        expect(subject.attributes[:something].type).to eq(:boolean)
      end

      it "coerces options" do
        subject.attribute "something", "type" => "boolean"
        expect(subject.attributes[:something].type).to eq(:boolean)
      end

      it "only allows valid types" do
        expect { subject.attribute :something, type: :fake_type }.to(
          raise_error(ActiveModel::ValidationError)
        )
      end
    end

    describe "schema" do
      it "creates a model from the configuration" do
        subject.attribute :something_enabled
        subject.attribute :comments_enabled

        configuration = subject.schema.new(
          something_enabled: true,
          comments_enabled: false,
          invalid_option: true
        )

        expect(configuration.something_enabled).to eq(true)
        expect(configuration.comments_enabled).to eq(false)

        expect(configuration.attributes).to include(something_enabled: true)
        expect(configuration.attributes).to include(comments_enabled: false)
        expect(configuration.attributes).to_not include(invalid_option: true)
      end
    end
  end
end
