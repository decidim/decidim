# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslationsHelper do
    describe "#translated_attribute" do
      let(:organization) { double(default_locale: "en") }

      before do
        allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
        allow(helper).to receive(:current_organization).and_return(organization)
      end

      it "translates the attribute against the current locale" do
        attribute = { "ca" => "Hola", "zh-CN" => "你好" }

        I18n.with_locale(:'zh-CN') do
          expect(helper.translated_attribute(attribute)).to eq("你好")
        end
      end

      context "when there is no translation for the given locale" do
        context "when the default_locale is present" do
          it "uses the default locale" do
            attribute = { "ca" => "Hola", "en" => "Hello" }

            I18n.with_locale(:'zh-CN') do
              expect(helper.translated_attribute(attribute)).to eq("Hello")
            end
          end
        end

        context "when the default locale is not present" do
          it "returns an empty string" do
            attribute = { "ca" => "Hola" }

            I18n.with_locale(:'zh-CN') do
              expect(helper.translated_attribute(attribute)).to eq("")
            end
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
  end
end
