# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe QuestionnaireForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization:
          )
        end

        let(:body_english) { "First question" }
        let(:current_organization) { create(:organization) }

        let(:questions) do
          [
            {
              body: {
                "en" => body_english,
                "ca" => "Primera pregunta",
                "es" => "Primera pregunta"
              },
              position: 0,
              question_type: "single_option",
              answer_options: [
                { "body" => { "en" => "A" } },
                { "body" => { "en" => "B" } },
                { "body" => { "en" => "C" } }
              ]
            },
            {
              body: {
                "en" => "Second question",
                "ca" => "Segona pregunta",
                "es" => "Segunda pregunta"
              },
              position: 1,
              question_type: "multiple_option",
              answer_options: [
                { "body" => { "en" => "A" } },
                { "body" => { "en" => "B" } },
                { "body" => { "en" => "C" } }
              ]
            }
          ]
        end

        let(:attributes) do
          {
            "questionnaire" => {
              "questions" => questions
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when a question is not valid" do
          let(:body_english) { "" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
