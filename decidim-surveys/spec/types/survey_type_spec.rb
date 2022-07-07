# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Surveys
    describe SurveyType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:survey) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the survey was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the survey was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "questionnaire" do
        let(:query) { "{ questionnaire { id }} " }

        it "returns the questionnaire" do
          expect(response["questionnaire"]["id"]).to eq(model.questionnaire.id.to_s)
        end
      end
    end
  end
end
