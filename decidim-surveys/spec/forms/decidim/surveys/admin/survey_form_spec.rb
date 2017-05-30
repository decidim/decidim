# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe SurveyForm do
        let(:current_organization) { create(:organization) }

        let(:description) do
          {
            "en" => "<p>Content</p>",
            "ca" => "<p>Contingut</p>",
            "es" => "<p>Contenido</p>"
          }
        end

        let(:questions) do
          [
            {
              body: {
                "en" => "First question",
                "ca" => "Primera pregunta",
                "es" => "Primera pregunta"
              },
              position: 0,
              question_type: "short_answer"
            },
            {
              body: {
                "en" => "Second question",
                "ca" => "Segona pregunta",
                "es" => "Segunda pregunta"
              },
              position: 1,
              mandatory: true,
              question_type: "short_answer"
            }
          ]
        end

        let(:attributes) do
          {
            "survey" => {
              "description" => description,
              "questions" => questions
            }
          }
        end

        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
