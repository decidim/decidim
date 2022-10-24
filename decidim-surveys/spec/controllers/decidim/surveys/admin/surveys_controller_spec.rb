# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe SurveysController, type: :controller do
        routes { Decidim::Surveys::AdminEngine.routes }

        let(:component) { survey.component }
        let(:survey) { create(:survey) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let(:answers) do
          survey.questionnaire.questions.map do |question|
            create(:answer, questionnaire: survey.questionnaire, question:, user:)
          end
        end

        let(:session_token) { answers.first.session_token }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user, scope: :user
        end

        describe "index" do
          let(:survey) { create(:survey) }
          let(:params) do
            {
              component_id: survey.component.id,
              participatory_process_slug: survey.component.participatory_space.slug,
              id: survey.id
            }
          end

          it "renders the index template" do
            get :index, params: params
            expect(response).to render_template(:index)
          end
        end

        describe "show" do
          let(:params) do
            {
              component_id: survey.component.id,
              participatory_process_slug: survey.component.participatory_space.slug,
              id: survey.id,
              session_token:
            }
          end

          it "renders the show template" do
            get :show, params: params
            expect(response).to render_template(:show)
          end
        end

        describe "export_response" do
          let(:filename) { "Response for #{session_token}.pdf" }
          let(:params) do
            {
              component_id: survey.component.id,
              participatory_process_slug: survey.component.participatory_space.slug,
              id: survey.id,
              session_token:
            }
          end

          it "redirects with a flash notice message" do
            get :export_response, params: params

            expect(response).to be_redirect
            expect(flash[:notice]).to be_present
          end
        end
      end
    end
  end
end
