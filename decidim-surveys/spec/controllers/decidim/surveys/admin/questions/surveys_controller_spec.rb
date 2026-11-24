# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      module Questions
        describe SurveysController do
          let(:component) { survey.component }
          let(:survey) { create(:survey) }
          let(:other_survey) { create(:survey, component:) }
          let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

          before do
            request.env["decidim.current_organization"] = component.organization
            request.env["decidim.current_component"] = component
            sign_in user, scope: :user
          end

          describe "GET edit" do
            let(:params) do
              {
                component_id: component.id,
                participatory_process_slug: component.participatory_space.slug,
                id: survey.id,
                survey_id: other_survey.id
              }
            end

            it "edits the survey identified by the route, ignoring the survey_id param" do
              get(:edit, params:)

              expect(response).to render_template(:edit)
              expect(assigns(:survey)).to eq(survey)
            end
          end

          describe "GET response_options" do
            let(:question) { create(:questionnaire_question, :with_response_options, questionnaire: survey.questionnaire) }
            let(:option) { question.response_options.first }

            context "when the survey_id param identifies the survey" do
              let(:params) do
                {
                  component_id: component.id,
                  participatory_process_slug: component.participatory_space.slug,
                  id: question.id,
                  survey_id: survey.id,
                  format: :json
                }
              end

              it "responds with the response options of the question" do
                get(:response_options, params:)

                expect(response.body).to include(Decidim::Forms::ResponseOptionPresenter.new(option).as_json.to_json)
              end
            end

            context "when the survey_id param is missing" do
              let(:params) do
                {
                  component_id: component.id,
                  participatory_process_slug: component.participatory_space.slug,
                  id: question.id,
                  format: :json
                }
              end

              it "raises a parameter missing error" do
                expect do
                  get(:response_options, params:)
                end.to raise_error(ActionController::ParameterMissing, /survey_id/)
              end
            end
          end
        end
      end
    end
  end
end
