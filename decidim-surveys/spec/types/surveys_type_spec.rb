# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"
require "decidim/core/test/shared_examples/scopable_interface_examples"

module Decidim
  module Surveys
    describe SurveysType, type: :graphql do
      include_context "with a graphql type"
      let(:model) { create(:surveys_component) }

      it_behaves_like "a component query type"

      describe "surveys" do
        let!(:component_surveys) { create_list(:survey, 2, component: model) }
        let!(:other_surveys) { create_list(:survey, 2) }

        let(:query) { "{ surveys { edges { node { id } } } }" }

        it "returns the published surveys" do
          ids = response["surveys"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_surveys.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_surveys.map(&:id).map(&:to_s))
        end
      end

      describe "survey" do
        let(:query) { "query Survey($id: ID!){ survey(id: $id) { id } }" }
        let(:variables) { { id: survey.id.to_s } }

        context "when the survey belongs to the component" do
          let!(:survey) { create(:survey, component: model) }

          it "finds the survey" do
            expect(response["survey"]["id"]).to eq(survey.id.to_s)
          end
        end

        context "when the survey doesn't belong to the component" do
          let!(:survey) { create(:survey, component: create(:surveys_component)) }

          it "returns null" do
            expect(response["survey"]).to be_nil
          end
        end
      end
    end
  end
end
