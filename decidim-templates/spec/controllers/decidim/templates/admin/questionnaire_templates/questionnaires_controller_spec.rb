# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      module QuestionnaireTemplates
        describe QuestionnairesController do
          routes { Decidim::Templates::AdminEngine.routes }

          let(:organization) { create(:organization) }
          let(:user) { create(:user, :confirmed, :admin, organization:) }
          let(:template) { create(:questionnaire_template, organization:) }
          let(:other_template) { create(:questionnaire_template) }
          let(:questionnaire) { template.templatable }
          let(:question) { create(:questionnaire_question, :with_response_options, questionnaire:) }
          let(:option) { question.response_options.first }

          before do
            request.env["decidim.current_organization"] = organization
            sign_in user, scope: :user
          end

          describe "GET response_options" do
            context "when the template_id param identifies the template" do
              let(:params) do
                {
                  id: question.id,
                  template_id: template.id,
                  format: :json
                }
              end

              it "responds with the response options of the question" do
                get(:response_options, params:)

                expect(response.body).to include(Decidim::Forms::ResponseOptionPresenter.new(option).as_json.to_json)
              end
            end

            context "when the template_id param is missing" do
              let(:params) do
                {
                  id: question.id,
                  format: :json
                }
              end

              it "raises a parameter missing error" do
                expect do
                  get(:response_options, params:)
                end.to raise_error(ActionController::ParameterMissing, /template_id/)
              end
            end

            context "when the template_id param identifies a template from another organization" do
              let(:params) do
                {
                  id: question.id,
                  template_id: other_template.id,
                  format: :json
                }
              end

              it "raises a record not found error" do
                expect do
                  get(:response_options, params:)
                end.to raise_error(ActiveRecord::RecordNotFound)
              end
            end
          end
        end
      end
    end
  end
end
