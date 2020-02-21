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
            create(:answer, questionnaire: survey.questionnaire, question: question, user: user)
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
              session_token: session_token
            }
          end

          it "renders the show template" do
            get :show, params: params
            expect(response).to render_template(:show)
          end
        end

        describe "export" do
          let(:filename) { "Responses.pdf" }
          let(:params) do
            {
              component_id: survey.component.id,
              participatory_process_slug: survey.component.participatory_space.slug,
              id: survey.id
            }
          end

          it "renders a pdf with all the responses" do
            get :export, params: params

            expect(response.content_type).to eq("application/pdf")
            expect(response.headers["Content-Disposition"]).to eq("inline; filename=\"#{filename}\"")
          end
        end

        describe "export_response" do
          let(:filename) { "Response for #{session_token}.pdf" }
          let(:params) do
            {
              component_id: survey.component.id,
              participatory_process_slug: survey.component.participatory_space.slug,
              id: survey.id,
              session_token: session_token
            }
          end

          it "renders a pdf with a response" do
            get :export_response, params: params

            expect(response.content_type).to eq("application/pdf")
            expect(response.headers["Content-Disposition"]).to eq("inline; filename=\"#{filename}\"")
          end
        end
      end
    end
  end
end
