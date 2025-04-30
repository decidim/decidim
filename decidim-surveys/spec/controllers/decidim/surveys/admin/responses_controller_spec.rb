# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe ResponsesController do
        routes { Decidim::Surveys::AdminEngine.routes }

        let(:component) { survey.component }
        let(:survey) { create(:survey, published_at: Time.current) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let(:responses) do
          survey.questionnaire.questions.map do |question|
            create(:response, questionnaire: survey.questionnaire, question:, user:)
          end
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user, scope: :user
        end

        describe "index" do
          let(:params) do
            {
              component_id: survey.component.id,
              participatory_process_slug: survey.component.participatory_space.slug,
              survey_id: survey.id
            }
          end

          it "renders the index template" do
            get(:index, params:)
            expect(response).to render_template(:index)
          end
        end

        describe "show" do
          let(:survey_response) { create(:response, questionnaire: survey.questionnaire, question: survey.questionnaire.questions.first, user:) }
          let(:params) do
            {
              component_id: survey.component.id,
              participatory_process_slug: survey.component.participatory_space.slug,
              survey_id: survey.id,
              id: survey_response.id
            }
          end

          it "renders the show template" do
            get(:show, params:)
            expect(response).to render_template(:show)
          end
        end

        describe "export_response" do
          let(:survey_response) { create(:response, questionnaire: survey.questionnaire, question: survey.questionnaire.questions.first, user:) }
          let(:params) do
            {
              component_id: survey.component.id,
              participatory_process_slug: survey.component.participatory_space.slug,
              survey_id: survey.id,
              id: survey_response.id
            }
          end

          it "redirects with a flash notice message" do
            get(:export_response, params:)

            expect(response).to be_redirect
            expect(flash[:notice]).to be_present
          end
        end
      end
    end
  end
end
