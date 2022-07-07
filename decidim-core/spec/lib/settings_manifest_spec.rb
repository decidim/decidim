# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SettingsManifest do
    subject { described_class.new }

    describe "attribute" do
      it "adds an attribute to the attribute hash with defaults" do
        subject.attribute :something # default: boolean
        expect(subject.attributes[:something].type).to eq(:boolean)
      end

      it "symbolizes the attribute's name" do
        subject.attribute "something"
        expect(subject.attributes[:something].type).to eq(:boolean)
      end

      it "coerces options" do
        subject.attribute "something", "type" => :boolean, "default" => true
        expect(subject.attributes[:something].type).to eq(:boolean)
        expect(subject.attributes[:something].default_value).to be(true)
      end

      it "stores presenceness" do
        subject.attribute :something # default: false
        expect(subject.attributes[:something].required).to be(false)

        subject.attribute :something, required: true
        expect(subject.attributes[:something].required).to be(true)

        subject.attribute :something, required: false
        expect(subject.attributes[:something].required).to be(false)
      end

      it "stores `translated`" do
        subject.attribute :something # default: false
        expect(subject.attributes[:something].translated).to be(false)

        subject.attribute :something, translated: true
        expect(subject.attributes[:something].translated).to be(true)

        subject.attribute :something, translated: false
        expect(subject.attributes[:something].translated).to be(false)
      end

      it "stores `editor`" do
        subject.attribute :something # default: false
        expect(subject.attributes[:something].editor).to be(false)

        subject.attribute :something, editor: true
        expect(subject.attributes[:something].editor).to be(true)

        subject.attribute :something, editor: false
        expect(subject.attributes[:something].editor).to be(false)
      end

      it "stores `required_for_authorization`" do
        subject.attribute :something # default: false
        expect(subject.attributes[:something].required_for_authorization).to be(false)

        subject.attribute :something, required_for_authorization: true
        expect(subject.attributes[:something].required_for_authorization).to be(true)

        subject.attribute :something, required_for_authorization: false
        expect(subject.attributes[:something].required_for_authorization).to be(false)
      end

      it "stores `readonly`" do
        subject.attribute :something
        expect(subject.attributes[:something].readonly?({})).to be_nil

        subject.attribute :something, readonly: ->(_context) { true }
        expect(subject.attributes[:something].readonly?({})).to be(true)

        subject.attribute :something, readonly: ->(_context) { false }
        expect(subject.attributes[:something].readonly?({})).to be(false)
      end

      it "stores `choices`" do
        subject.attribute :something
        expect(subject.attributes[:something].build_choices).to be_nil

        subject.attribute :something, choices: %w(a b c)
        expect(subject.attributes[:something].build_choices).to eq(%w(a b c))

        subject.attribute :something, choices: -> { %w(a b c) }
        expect(subject.attributes[:something].build_choices).to eq(%w(a b c))
      end

      describe "supported types" do
        it "supports booleans" do
          attribute = SettingsManifest::Attribute.new(type: :boolean)
          expect(attribute.type_class).to eq(:boolean)
          expect(attribute.default_value).to be(false)
        end

        it "supports integers" do
          attribute = SettingsManifest::Attribute.new(type: :integer)
          expect(attribute.type_class).to eq(Integer)
          expect(attribute.default_value).to eq(0)
        end

        it "supports strings" do
          attribute = SettingsManifest::Attribute.new(type: :string)
          expect(attribute.type_class).to eq(String)
          expect(attribute.default_value).to be_nil
        end

        it "supports texts" do
          attribute = SettingsManifest::Attribute.new(type: :text)
          expect(attribute.type_class).to eq(String)
          expect(attribute.default_value).to be_nil
        end

        it "supports arrays" do
          attribute = SettingsManifest::Attribute.new(type: :array)
          expect(attribute.type_class).to eq(Array)
          expect(attribute.default_value).to eq([])
        end

        it "supports enums" do
          attribute = SettingsManifest::Attribute.new(type: :enum)
          expect(attribute.type_class).to eq(String)
          expect(attribute.default_value).to be_nil
        end

        it "supports select" do
          attribute = SettingsManifest::Attribute.new(type: :select)
          expect(attribute.type_class).to eq(String)
          expect(attribute.default_value).to be_nil
        end

        it "supports scopes" do
          attribute = SettingsManifest::Attribute.new(type: :scope)
          expect(attribute.type_class).to eq(Integer)
          expect(attribute.default_value).to be_nil
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

        expect(settings.something_enabled).to be(true)
        expect(settings.comments_enabled).to be(false)

        expect(settings.attributes).to include("something_enabled" => true)
        expect(settings.attributes).to include("comments_enabled" => false)
        expect(settings.attributes).not_to include("invalid_option" => true)
      end

      it "adds presence validation to the model according the presenceness of the setting" do
        subject.attribute :something_enabled
        subject.attribute :comments_enabled, required: true

        settings = subject.schema.new(something_enabled: true)
        expect(settings).not_to be_valid

        settings = subject.schema.new(comments_enabled: true)
        expect(settings).to be_valid
      end

      it "allows passing an optional argument `default_locale` that defaults to nil" do
        settings = subject.schema.new({}, "en")
        expect(settings.default_locale).to eq("en")

        settings = subject.schema.new({})
        expect(settings.default_locale).to be_nil
      end

      context "when adding presence validation to the model from a translated setting" do
        before do
          subject.attribute :translatable_setting, type: :text, translated: true, required: true
        end

        context "and `default_locale` is present" do
          let(:default_locale) { "en" }

          it "allows to validate the translatable presence of the setting" do
            settings = subject.schema.new({ translatable_setting_en: "Some text" }, default_locale)
            expect(settings).to be_valid

            settings = subject.schema.new({ translatable_setting_en: "" }, default_locale)
            expect(settings).not_to be_valid
          end
        end

        context "and `default_locale` is nil" do
          let(:default_locale) { nil }

          it "raises an error when trying to validate the translatable presence of the setting" do
            settings = subject.schema.new({ translatable_setting_en: "Some text" }, default_locale)
            expect { settings.validate }.to raise_error(NoMethodError)
          end
        end
      end
    end
  end
end
