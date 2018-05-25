# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe QuestionnaireAnswerOptionForm do
        subject do
          described_class.from_params(
            questionnaire_answer_option: attributes
          ).with_context(current_organization: organization)
        end

        let(:organization) { create :organization }

        let(:attributes) do
          {
            body_en: "Body en",
            body_ca: "Body ca",
            body_es: "Body es"
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the main body is not present" do
          before { attributes[:body_en] = "" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
