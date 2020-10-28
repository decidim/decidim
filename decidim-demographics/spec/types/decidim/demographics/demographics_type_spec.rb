# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Demographics
    describe DemographicsType, type: :graphql do
      include_context "with a graphql type"
      let(:model) { create(:demographic) }

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

      describe "nationality" do
        let(:query) { "{ nationality }" }

        it "returns the nationality field" do
          expect(response["nationality"]).to eq(model.nationality)
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
