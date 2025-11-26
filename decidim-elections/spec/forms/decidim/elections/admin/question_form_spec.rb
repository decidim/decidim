# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim
  module Elections
    module Admin
      describe QuestionForm do
        let!(:questionable) { create(:election) }
        let!(:question_type) { Decidim::Elections::Question.question_types.first }
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

        describe "max_choices validation" do
          let(:attributes) do
            {
              body_en: body_en,
              description_en: description_en,
              question_type: question_type,
              response_options: response_options,
              max_choices: max_choices
            }
          end

          context "when max_choices is valid" do
            let(:max_choices) { 2 }

            it { is_expected.to be_valid }
          end

          context "when max_choices is greater than number of options" do
            let(:max_choices) { 10 }

            it { is_expected.not_to be_valid }

            it "adds an error on max_choices" do
              subject.valid?
              expect(subject.errors[:max_choices]).not_to be_empty
            end
          end

          context "when max_choices is 1" do
            let(:max_choices) { 1 }

            it { is_expected.not_to be_valid }

            it "adds an error on max_choices" do
              subject.valid?
              expect(subject.errors[:max_choices]).not_to be_empty
            end
          end

          context "when max_choices is nil" do
            let(:max_choices) { nil }

            it { is_expected.to be_valid }
          end

          context "when max_choices is blank string" do
            let(:max_choices) { "" }

            it { is_expected.to be_valid }
          end
        end

        describe "#number_of_options" do
          it "returns the count of response options" do
            expect(subject.number_of_options).to eq(2)
          end

          context "when there are no response options" do
            let(:response_options) { {} }

            it "returns 0" do
              expect(subject.number_of_options).to eq(0)
            end
          end
        end

        it_behaves_like "form to param", default_id: "questionnaire-question-id"
      end
    end
  end
end
