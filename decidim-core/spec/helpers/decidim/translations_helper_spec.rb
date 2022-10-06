# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslationsHelper do
    describe "#translated_attribute" do
      let(:organization) { double(default_locale: "en", enable_machine_translations?: true, machine_translation_prioritizes_translation?: true) }

      before do
        allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
        allow(helper).to receive(:current_organization).and_return(organization)
      end

      it "translates the attribute against the current locale" do
        attribute = { "ca" => "Hola", "zh-CN" => "你好" }

        I18n.with_locale(:"zh-CN") do
          expect(helper.translated_attribute(attribute)).to eq("你好")
        end
      end

      context "when there is no translation for the given locale" do
        context "when the default_locale is present" do
          it "uses the default locale" do
            attribute = { "ca" => "Hola", "en" => "Hello" }

            I18n.with_locale(:"zh-CN") do
              expect(helper.translated_attribute(attribute)).to eq("Hello")
            end
          end
        end

        context "when the default locale is not present" do
          it "returns the first available string" do
            attribute = { "ca" => "Hola" }

            I18n.with_locale(:"zh-CN") do
              expect(helper.translated_attribute(attribute)).to eq("Hola")
            end
          end
        end
      end

      context "when given an organization" do
        let(:other_organization) { double(default_locale: "ca", enable_machine_translations?: true, machine_translation_prioritizes_translation?: true) }

        it "uses the given organization default locale" do
          attribute = { "ca" => "Hola", "en" => "Hello" }

          I18n.with_locale(:"zh-CN") do
            expect(helper.translated_attribute(attribute, other_organization)).to eq("Hola")
          end
        end
      end
    end

    describe "#multi_translation" do
      context "when given a key and a list of locales" do
        it "returns a hash scoped to that list of locales" do
          result = TranslationsHelper.multi_translation("booleans.true", [:en, :ca])
          expect(result.keys.length).to eq(2)
          expect(result).to include(en: "Yes", ca: "Sí")
        end
      end

      context "when given only a key" do
        it "returns a hash scoped to the available list of locales" do
          result = TranslationsHelper.multi_translation("booleans.true")
          expect(result.keys.length).to eq(3)
          expect(result).to include(en: "Yes", ca: "Sí", es: "Sí")
        end
      end
    end

    describe "#ensure_translatable" do
      let(:locales) { [:en, :ca] }

      context "when given a non-hash and a list of locales" do
        let(:value) { nil }

        it "returns a hash with each locale as the key and empty string values" do
          result = TranslationsHelper.ensure_translatable(value, locales)
          expect(result.keys.length).to eq(locales.length)
          expect(result).to include("en" => "", "ca" => "")
        end
      end

      context "when given a hash with value only for one of the locales" do
        let(:value) { { en: "Value" } }

        it "returns a hash with each locale as the key and empty string values" do
          result = TranslationsHelper.ensure_translatable(value, [:en, :ca])
          expect(result.keys.length).to eq(locales.length)
          expect(result).to include("en" => "Value", "ca" => "")
        end
      end

      context "when given a hash with each locale having a value" do
        let(:value) { { en: "Value", ca: "Valor" } }

        it "returns a hash with each locale as the key and empty string values" do
          result = TranslationsHelper.ensure_translatable(value, [:en, :ca])
          expect(result.keys.length).to eq(locales.length)
          expect(result).to include("en" => "Value", "ca" => "Valor")
        end
      end

      describe "#translated_in_current_locale" do
        let(:value) { { "en" => "Hello", "pt-BR" => "Olá", "ca" => "" } }

        context "when translated in current locale" do
          it "returns true" do
            I18n.with_locale(:en) do
              expect(TranslationsHelper).to be_translated_in_current_locale(value)
            end
          end
        end

        context "when not translated in current locale" do
          it "returns false" do
            I18n.with_locale(:ca) do
              expect(TranslationsHelper).not_to be_translated_in_current_locale(value)
            end
          end
        end
      end
    end
  end
end
