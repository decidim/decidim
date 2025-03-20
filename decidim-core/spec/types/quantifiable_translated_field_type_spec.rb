# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe QuantifiableTranslatedFieldType do
      include_context "with a graphql class type"

      let(:model) do
        {
          single: {
            ca: "Hola",
            en: "Hello"
          },
          plural: {
            ca: "Holas",
            en: "Hellos"
          }
        }
      end

      describe "single" do
        let(:query) { "{ single { locales translations { locale text } } }" }

        it "returns the available locales and translations" do
          expect(response["single"]["locales"]).to include("en", "ca")
          expect(response["single"]["translations"]).to include(
            { "locale" => "ca", "text" => "Hola" },
            { "locale" => "en", "text" => "Hello" }
          )
        end
      end

      describe "plural" do
        let(:query) { "{ plural { locales translations { locale text } } }" }

        it "returns the available locales and translations" do
          expect(response["plural"]["locales"]).to include("en", "ca")
          expect(response["plural"]["translations"]).to include(
            { "locale" => "ca", "text" => "Holas" },
            { "locale" => "en", "text" => "Hellos" }
          )
        end
      end
    end
  end
end
