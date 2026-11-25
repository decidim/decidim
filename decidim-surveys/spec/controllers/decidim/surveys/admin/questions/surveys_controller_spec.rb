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

          describe "GET edit_questions" do
            let(:params) do
              {
                component_id: component.id,
                participatory_process_slug: component.participatory_space.slug,
                id: survey.id
              }
            end

            def count_queries
              queries = []
              callback = lambda do |_name, _start, _finish, _id, payload|
                queries << payload[:sql] unless payload[:cached] || payload[:name] == "SCHEMA"
              end

              ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }

              queries
            end

            def question_association_queries(queries)
              queries.grep(/FROM "decidim_forms_(response_options|display_conditions|question_matrix_rows)"/)
            end

            def create_questions(questionnaire, count)
              count.times do
                question = create(:questionnaire_question, :with_response_options, question_type: :matrix_single, questionnaire:)
                create_list(:question_matrix_row, 2, question:)
              end
            end

            context "when rendering the questions form" do
              render_views

              routes { Decidim::Surveys::AdminEngine.routes }

              let(:questionnaire) { create(:questionnaire, :with_all_questions) }
              let(:survey) { create(:survey, questionnaire:) }

              before do
                # Simulate the engine being mounted, so route helpers generated while
                # rendering do not need the participatory space mount parameters.
                routes.default_url_options[:script_name] = "/admin"
              end

              it "renders the questions form" do
                get(:edit_questions, params:)

                expect(response).to render_template("decidim/surveys/admin/questions/surveys/edit")
              end
            end

            context "when counting the queries of the page" do
              let(:questionnaire) { create(:questionnaire) }
              let(:survey) { create(:survey, questionnaire:) }

              it "does not increase the number of association queries when there are more questions" do
                create_questions(questionnaire, 2)

                # Warm-up request materialises lazy lets before measuring.
                get(:edit_questions, params:)
                expect(response).to have_http_status(:ok)

                few_queries = count_queries { get(:edit_questions, params:) }
                expect(response).to have_http_status(:ok)

                create_questions(questionnaire, 4)

                many_queries = count_queries { get(:edit_questions, params:) }
                expect(response).to have_http_status(:ok)

                expect(question_association_queries(many_queries).size)
                  .to eq(question_association_queries(few_queries).size)

                # The eager-loaded associations should be fetched in batches, never per question.
                expect(question_association_queries(many_queries).grep(/"decidim_question_id" =/)).to be_empty
              end
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
