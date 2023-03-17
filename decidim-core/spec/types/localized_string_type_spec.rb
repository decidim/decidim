# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe LocalizedStringType do
      include_context "with a graphql class type"

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

        it "returns the text" do
          expect(response).to include("text" => "A test locale.")
        end
      end

      describe "machineTranslated" do
        let(:query) { "{ machineTranslated }" }

        it "returns false by default" do
          expect(response).to include("machineTranslated" => false)
        end

        context "when the model responds to machine_translated" do
          let(:model) { OpenStruct.new(machine_translated: true) }

          it "returns the correct value" do
            expect(response).to include("machineTranslated" => true)
          end

          context "and the model returns false" do
            let(:model) { OpenStruct.new(machine_translated: false) }

            it "returns the correct value" do
              expect(response).to include("machineTranslated" => false)
            end
          end

          context "and the model returns a nil" do
            let(:model) { OpenStruct.new(machine_translated: nil) }

            it "returns false" do
              expect(response).to include("machineTranslated" => false)
            end
          end

          context "and the model returns a non-boolean evaluating as present" do
            let(:model) { OpenStruct.new(machine_translated: "true") }

            it "returns true" do
              expect(response).to include("machineTranslated" => true)
            end
          end

          context "and the model returns a non-boolean evaluating as blank" do
            let(:model) { OpenStruct.new(machine_translated: "") }

            it "returns false" do
              expect(response).to include("machineTranslated" => false)
            end
          end
        end
      end
    end
  end
end
