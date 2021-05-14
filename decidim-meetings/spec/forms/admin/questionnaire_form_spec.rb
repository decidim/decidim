# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe QuestionnaireForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        let(:current_organization) { create(:organization) }
        let(:position) { 0 }

        let(:questions) do
          [
            {
              body: {
                "en" => "First question",
                "ca" => "Primera pregunta",
                "es" => "Primera pregunta"
              },
              position: position,
              question_type: "short_answer"
            },
            {
              body: {
                "en" => "Second question",
                "ca" => "Segona pregunta",
                "es" => "Segunda pregunta"
              },
              position: 1,
              question_type: "short_answer"
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
          let(:position) { "a" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
