# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe TranslatedFieldType do
      include_context "with a graphql class type"

      let(:model) do
        {
          ca: "Hola",
          en: "Hello"
        }
      end

      describe "locales" do
        let(:query) { "{ locales }" }

        it "returns the available locales" do
          expect(response["locales"]).to include("en", "ca")
        end
      end

      describe "translations" do
        context "when locales are not provided" do
          let(:query) { "{ translations { locale text }}" }

          it "returns all the translations" do
            translations = response["translations"]
            expect(translations.length).to eq(2)
            expect(translations).to include("locale" => "ca", "text" => "Hola")
            expect(translations).to include("locale" => "en", "text" => "Hello")
          end
        end

        context "when locales are provided" do
          let(:query) { '{ translations(locales: ["ca"]) { locale text }}' }

          it "returns the translations on the provided locales" do
            translations = response["translations"]
            expect(translations).to include("locale" => "ca", "text" => "Hola")
            expect(translations).not_to include("locale" => "en", "text" => "Hello")
          end
        end
      end

      describe "translation" do
        context "when the locale is found" do
          let(:query) { '{ translation(locale: "ca") }' }

          it "returns the translation for that language" do
            translation = response["translation"]
            expect(translation).to eq("Hola")
          end
        end

        context "when the locale is not found" do
          let(:query) { '{ translation(locale: "fake") }' }

          it "returns a null value" do
            translation = response["translation"]
            expect(translation).to be_nil
          end
        end
      end
    end
  end
end
