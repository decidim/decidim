# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe PublishResponsesController do
        let(:survey) { create(:survey) }
        let(:component) { survey.component }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:foreign_question) { create(:questionnaire_question) }
        let(:question) { survey.questionnaire.questions.first }
        let(:params) do
          {
            component_id: component.id,
            participatory_process_slug: component.participatory_space.slug,
            survey_id: survey.id,
            id: foreign_question.id
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user, scope: :user
        end

        describe "update" do
          it "publishes a question from the survey questionnaire" do
            put(:update, params: params.merge(id: question.id))

            expect(response).to have_http_status(:ok)
            expect(question.reload.survey_responses_published_at).to be_present
          end

          it "does not publish a question from another questionnaire" do
            put(:update, params:)

            expect(response).to have_http_status(:unprocessable_content)
            expect(foreign_question.reload.survey_responses_published_at).to be_nil
          end
        end

        describe "destroy" do
          let(:foreign_question) { create(:questionnaire_question, survey_responses_published_at: Time.current) }

          before do
            question.update!(survey_responses_published_at: Time.current)
          end

          it "unpublishes a question from the survey questionnaire" do
            delete(:destroy, params: params.merge(id: question.id))

            expect(response).to have_http_status(:ok)
            expect(question.reload.survey_responses_published_at).to be_nil
          end

          it "does not unpublish a question from another questionnaire" do
            delete(:destroy, params:)

            expect(response).to have_http_status(:unprocessable_content)
            expect(foreign_question.reload.survey_responses_published_at).to be_present
          end
        end
      end
    end
  end
end
