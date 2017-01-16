require "spec_helper"

module Decidim
  describe FeatureSettingsManifest do
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
        subject.attribute "something", "type" => "boolean", "default" => true
        expect(subject.attributes[:something].type).to eq(:boolean)
        expect(subject.attributes[:something].default_value).to eq(true)
      end

      it "only allows valid types" do
        expect { subject.attribute :something, type: :fake_type }.to(
          raise_error(ActiveModel::ValidationError)
        )
      end
    end

    describe "schema" do
      it "creates a model from the settings" do
        subject.attribute :something_enabled
        subject.attribute :comments_enabled

        settings = subject.schema.new(
          something_enabled: true,
          comments_enabled: false,
          invalid_option: true
        )

        expect(settings.something_enabled).to eq(true)
        expect(settings.comments_enabled).to eq(false)

        expect(settings.attributes).to include(something_enabled: true)
        expect(settings.attributes).to include(comments_enabled: false)
        expect(settings.attributes).to_not include(invalid_option: true)
      end
    end
  end
end
