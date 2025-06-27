# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim
  module Elections
    module Admin
      describe QuestionForm do
        let!(:questionable) { create(:election) }
        let!(:position) { 0 }
        let!(:question_type) { Decidim::Elections::Question::QUESTION_TYPES.first }
        let!(:body_en) { "Body en" }
        let!(:description_en) { "Description en" }
        let!(:response_options) do
          {
            "0" => { "body" => { "en" => "Option A" } },
            "1" => { "body" => { "en" => "Option B" } }
          }
        end

        let(:attributes) do
          {
            body_en: body_en,
            description_en: description_en,
            question_type: question_type,
            position: position,
            response_options: response_options
          }
        end

        subject do
          described_class.from_params(
            question: attributes
          ).with_context(current_organization: questionable.organization)
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the position is not present" do
          let(:position) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the question_type is not known" do
          let(:question_type) { "foo" }

          it { is_expected.not_to be_valid }
        end

        context "when the question has no response options" do
          let(:response_options) { {} }

          it { is_expected.not_to be_valid }
        end

        context "when the body is missing a locale translation" do
          let(:body_en) { "" }

          it { is_expected.not_to be_valid }
        end

        it_behaves_like "form to param", default_id: "questionnaire-question-id"
      end
    end
  end
end
