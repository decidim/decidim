# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim
  module Forms
    module Admin
      describe QuestionMatrixRowForm do
        subject do
          described_class.from_params(
            question_matrix_row: attributes
          ).with_context(current_organization: questionable.organization)
        end

        let!(:questionable) { create(:dummy_resource) }
        let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }
        let!(:position) { 0 }

        let(:deleted) { "false" }
        let(:attributes) do
          {
            body_en: "Body en",
            body_ca: "Body ca",
            body_es: "Body es",
            position:,
            deleted:
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the position is not present" do
          let!(:position) { nil }

          it { is_expected.to be_valid }
        end

        context "when the body is missing a locale translation" do
          before do
            attributes[:body_en] = ""
          end

          context "when the question is not deleted" do
            let(:deleted) { "false" }

            it { is_expected.not_to be_valid }
          end

          context "when the question is deleted" do
            let(:deleted) { "true" }

            it { is_expected.to be_valid }
          end
        end

        it_behaves_like "form to param", default_id: "questionnaire-question-matrix-row-id"
      end
    end
  end
end
