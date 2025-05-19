# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe QuestionsController do
        routes { Decidim::Elections::AdminEngine.routes }

        let(:component) { create(:elections_component) }
        let(:organization) { component.organization }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:election) { create(:election, component:) }
        let!(:questionnaire) { create(:election_questionnaire, questionnaire_for: election) }
        let!(:question) { create(:election_question, questionnaire:, body: { "en" => "Question 1" }, question_type: "multiple_option") }
        let!(:response_option1) { create(:election_response_option, question:, body: { "en" => "Option 1" }) }
        let!(:response_option2) { create(:election_response_option, question:, body: { "en" => "Option 2" }) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "GET edit_questions" do
          it "renders the edit_questions template" do
            get :edit_questions, params: { id: election.id }
            expect(response).to render_template("decidim/elections/admin/questions/edit_questions")
            expect(assigns(:form)).to be_a(Decidim::Elections::Admin::QuestionnaireForm)
          end
        end

        describe "PATCH update" do
          let(:valid_questions_params) do
            [
              {
                id: question.id,
                body_en: "Updated Question",
                question_type: "multiple_option",
                position: 0,
                response_options: [
                  { body_en: "Updated Option 1" },
                  { body_en: "Updated Option 2" }
                ]
              }
            ]
          end

          let(:invalid_questions_params) do
            [
              {
                id: question.id,
                body_en: "", # Invalid body
                question_type: "multiple_option",
                position: 0,
                response_options: [
                  { body_en: "Only One Option" }
                ]
              }
            ]
          end

          it "updates the questionnaire and redirects with notice" do
            patch :update, params: { id: election.id, questionnaire: { questions: valid_questions_params } }
            expect(response).to redirect_to(edit_questions_election_path(election))
            expect(flash[:notice]).to be_present
          end

          it "renders edit_questions on invalid data (less than 2 options) and shows alert" do
            patch :update, params: { id: election.id, questionnaire: { questions: invalid_questions_params } }
            expect(response).to render_template("decidim/elections/admin/questions/edit_questions")
            expect(flash.now[:alert]).to be_present
          end
        end
      end
    end
  end
end
