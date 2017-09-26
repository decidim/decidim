# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe SurveyQuestionForm do
        let!(:survey) { create(:survey) }
        let!(:position) { 0 }
        let!(:question_type) { SurveyQuestion::TYPES.first }
        let!(:organization) { create :organization }
        let(:deleted) { "false" }
        let(:attributes) do
          {
            body_en: "Body en",
            body_ca: "Body ca",
            body_es: "Body es",
            question_type: question_type,
            position: position,
            deleted: deleted
          }
        end

        subject do
          described_class.from_params(attributes).with_context(current_feature: survey.feature, current_organization: organization)
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the position is not present" do
          let!(:position) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the question_type is not known" do
          let!(:question_type) { "foo" }

          it { is_expected.not_to be_valid }
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
      end
    end
  end
end
