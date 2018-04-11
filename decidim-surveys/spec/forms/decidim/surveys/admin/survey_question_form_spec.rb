# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe SurveyQuestionForm do
        subject do
          described_class.from_params(
            survey_question: attributes
          ).with_context(current_component: survey.component, current_organization: organization)
        end

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

        context "when the question has no answer options" do
          it "is invalid if max_choices present" do
            attributes[:max_choices] = 1

            expect(subject).not_to be_valid
          end
        end

        context "when the question has answer options" do
          let!(:question_type) { "multiple_option" }

          it "is valid when max_choices under the number of options" do
            attributes[:max_choices] = 3
            attributes[:answer_options] = {
              "0" => { "body" => { "en" => "A" } },
              "1" => { "body" => { "en" => "B" } },
              "2" => { "body" => { "en" => "C" } }
            }

            expect(subject).to be_valid
          end

          it "is invalid when max_choices over the number of options" do
            attributes[:max_choices] = 4
            attributes[:answer_options] = {
              "0" => { "body" => { "en" => "A" } },
              "1" => { "body" => { "en" => "B" } },
              "2" => { "body" => { "en" => "C" } }
            }

            expect(subject).not_to be_valid
          end

          it "is valid when max choices under the number of options" do
            attributes[:max_choices] = 2
            attributes[:answer_options] = {
              "0" => { "body" => { "en" => "A" } },
              "1" => { "body" => { "en" => "B" } },
              "2" => { "body" => { "en" => "C" } }
            }

            expect(subject).to be_valid
          end
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
