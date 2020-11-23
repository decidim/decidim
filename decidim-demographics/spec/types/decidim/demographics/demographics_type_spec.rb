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

      describe "nationalities" do
        let(:query) { "{ nationalities }" }

        it "returns the nationalities field" do
          expect(response["nationalities"]).to eq(model.nationalities)
        end
      end

      describe "residences" do
        let(:query) { "{ residences }" }

        it "returns the residences field" do
          expect(response["residences"]).to eq(model.residences)
        end
      end

      describe "current_occupations" do
        let(:query) { "{ current_occupations }" }

        it "returns the current_occupations field" do
          expect(response["current_occupations"]).to eq(model.current_occupations)
        end
      end

      describe "living_condition" do
        let(:query) { "{ living_condition }" }

        it "returns the living_condition field" do
          expect(response["living_condition"]).to eq(model.living_condition)
        end
      end

      describe "attended_eu_event" do
        let(:query) { "{ attended_before }" }

        it "returns the attended_before field" do
          expect(response["attended_before"]).to eq(model.attended_before)
        end
      end

      describe "newsletter_sign_in" do
        let(:query) { "{ newsletter_sign_in }" }

        it "returns the newsletter_sign_in field" do
          expect(response["newsletter_sign_in"]).to eq(model.newsletter_sign_in.to_s)
        end
      end

      describe "attended_before" do
        let(:query) { "{ attended_before }" }

        it "returns the attended_before field" do
          expect(response["attended_before"]).to eq(model.attended_before)
        end
      end
    end
  end
end
