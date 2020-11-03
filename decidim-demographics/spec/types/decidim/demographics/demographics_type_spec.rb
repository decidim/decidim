# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Demographics
    describe DemographicsType, type: :graphql do
      include_context "with a graphql type"
      let(:model) { create(:encrypted_demographic) }

      it_behaves_like "a component query type"

      describe "age" do
        let(:query) { "{ age }" }

        it "returns the age field" do
          expect(response["age"]).to eq(model.age)
        end
      end

      describe "gender" do
        let(:query) { "{ gender }" }

        it "returns the gender field" do
          expect(response["gender"]).to eq(model.gender)
        end
      end

      describe "nationalities" do
        let(:query) { "{ nationalities }" }

        it "returns the nationalities field" do
          expect(response["nationalities"]).to eq(model.nationalities)
        end

        context "when empty json field" do
          let(:model) { create(:encrypted_demographic, data: {}) }

          it "returns empty array" do
            expect(response["nationalities"]).to be_a(Array)
          end
        end
      end

      describe "background" do
        let(:query) { "{ background }" }

        it "returns the background field" do
          expect(response["background"]).to eq(model.background)
        end
      end

      describe "postal_code" do
        let(:query) { "{ postal_code }" }

        it "returns the postal_code field" do
          expect(response["postal_code"]).to eq(model.postal_code)
        end
      end
    end
  end
end
