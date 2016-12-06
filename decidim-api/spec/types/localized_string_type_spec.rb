# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_helpers"

module Decidim
  module Api
    describe LocalizedStringType do
      include Test::TypeHelpers

      let(:model) do
        OpenStruct.new(locale: "en", text: "A test locale.")
      end

      describe "locale" do
        let(:query) { "{ locale }" }

        it "returns the locale" do
          expect(response).to include("locale" => "en")
        end
      end

      describe "text" do
        let(:query) { "{ text }" }

        it "returns the text " do
          expect(response).to include("text" => "A test locale.")
        end
      end
    end
  end
end
