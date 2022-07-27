# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe AnswersController, type: :controller do
        routes { Decidim::Elections::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "PATCH update" do
          let(:datetime_format) { I18n.t("time.formats.decidim_short") }
          let(:component) { create(:elections_component) }
          let(:election) { create(:election, component:) }
          let(:question) { create(:question, election:) }
          let(:answer) { create(:election_answer, question:) }
          let(:answer_title) { answer.title }
          let(:answer_params) do
            {
              title: answer_title,
              description: answer.description,
              weight: answer.weight,
              attachment: {
                title: "",
                file: nil
              },
              photos: election.photos.map { |a| a.id.to_s }
            }
          end

          let(:params) do
            {
              id: answer.id,
              election_id: election.id,
              question_id: question.id,
              answer: answer_params
            }
          end

          it "updates the election" do
            allow(controller).to receive(:election_question_answers_path).and_return("/answers")

            patch :update, params: params

            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:found)
          end

          context "when the existing election has photos and there are other errors on the form" do
            include_context "with controller rendering the view" do
              let(:answer_title) { { en: "" } }
              let(:answer) { create(:election_answer, :with_photos, question:) }

              controller(AnswersController) do
                helper_method :proposals_picker_election_question_answers_path
                def proposals_picker_election_question_answers_path(_foo, _bar)
                  "/"
                end
              end

              it "displays the editing form with errors" do
                patch :update, params: params

                expect(flash[:alert]).not_to be_empty
                expect(response).to have_http_status(:ok)
                expect(subject).to render_template(:edit)
                expect(response.body).to include("There was a problem updating this answer")
              end
            end
          end
        end
      end
    end
  end
end
