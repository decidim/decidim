# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe QuestionnaireForm do
        let(:current_organization) { create(:organization) }

        let(:questions) do
          [
            {
              body: { "en" => "First question" },
              description: { "en" => "First description" },
              position: 0,
              question_type: "single_option",
              response_options: [
                { "body" => { "en" => "A" } },
                { "body" => { "en" => "B" } }
              ]
            },
            {
              body: { "en" => "Second question" },
              description: { "en" => "Second description" },
              position: 1,
              question_type: "multiple_option",
              response_options: [
                { "body" => { "en" => "C" } },
                { "body" => { "en" => "D" } }
              ]
            }
          ]
        end

        let(:attributes) do
          {
            "questions" => questions
          }
        end

        subject(:form) do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        context "when questions are present and valid" do
          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "when no questions are given" do
          let(:attributes) { { "questions" => [] } }

          it "is not valid and adds a base error" do
            expect(form).not_to be_valid
            expect(form.errors[:base]).to include(I18n.t("decidim.elections.admin.questionnaire_form.errors.at_least_one_question"))
          end
        end

        context "when all questions are marked as deleted" do
          let(:attributes) do
            {
              "questions" => [
                questions[0].merge(deleted: true),
                questions[1].merge(deleted: true)
              ]
            }
          end

          it "is not valid and adds a base error" do
            expect(form).not_to be_valid
            expect(form.errors[:base]).to include(I18n.t("decidim.elections.admin.questionnaire_form.errors.at_least_one_question"))
          end
        end

        context "when a question is not valid" do
          let(:questions) do
            [
              {
                body: { "en" => "" }, # invalid: empty body
                description: { "en" => "Some description" },
                position: 0,
                question_type: "single_option",
                response_options: [
                  { "body" => { "en" => "A" } },
                  { "body" => { "en" => "B" } }
                ]
              }
            ]
          end

          it "is not valid" do
            expect(form).not_to be_valid
          end
        end
      end
    end
  end
end
