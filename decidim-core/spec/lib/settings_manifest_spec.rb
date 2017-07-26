# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SettingsManifest do
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

      describe "supported types" do
        it "supports booleans" do
          attribute = SettingsManifest::Attribute.new(type: :boolean)
          expect(attribute.type_class).to eq(Virtus::Attribute::Boolean)
          expect(attribute.default_value).to eq(false)
        end

        it "supports integers" do
          attribute = SettingsManifest::Attribute.new(type: :integer)
          expect(attribute.type_class).to eq(Integer)
          expect(attribute.default_value).to eq(0)
        end

        it "supports strings" do
          attribute = SettingsManifest::Attribute.new(type: :string)
          expect(attribute.type_class).to eq(String)
          expect(attribute.default_value).to eq(nil)
        end

        it "supports texts" do
          attribute = SettingsManifest::Attribute.new(type: :text)
          expect(attribute.type_class).to eq(String)
          expect(attribute.default_value).to eq(nil)
        end
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
        expect(settings.attributes).not_to include(invalid_option: true)
      end
    end
  end
end
