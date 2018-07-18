# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe AnswerForm do
      subject do
        described_class.from_model(survey_answer).with_context(current_component: survey.component)
      end

      let(:mandatory) { false }
      let(:question_type) { "short_answer" }
      let(:max_choices) { nil }

      let!(:survey) { create(:survey) }
      let!(:user) { create(:user, organization: survey.component.participatory_space.organization) }

      let!(:survey_question) do
        create(
          :survey_question,
          survey: survey,
          mandatory: mandatory,
          question_type: question_type,
          max_choices: max_choices,
          answer_options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      let!(:survey_answer) { build(:survey_answer, user: user, survey: survey, question: survey_question) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when the question is mandatory" do
        let(:mandatory) { true }

        context "and question type is not multiple choice" do
          let(:question_type) { "long_answer" }

          it "is not valid if body is not present" do
            subject.body = nil
            expect(subject).not_to be_valid

            subject.body = ""
            expect(subject).not_to be_valid
          end
        end

        context "and question type is multiple choice" do
          let(:question_type) { "multiple_option" }

          it "is not valid if choices are empty" do
            subject.choices = []
            expect(subject).not_to be_valid
          end
        end
      end

      context "when the question has max_choices set" do
        let(:question_type) { "multiple_option" }

        let(:max_choices) { 2 }

        it "is valid if few enough options checked" do
          subject.choices = [
            { "answer_option_id" => "1", "body" => "foo" },
            { "answer_option_id" => "2", "body" => "bar" }
          ]

          expect(subject).to be_valid
        end

        it "is not valid if too many options checked" do
          subject.choices = [
            { "answer_option_id" => "1", "body" => "foo" },
            { "answer_option_id" => "2", "body" => "bar" },
            { "answer_option_id" => "3", "body" => "baz" }
          ]

          expect(subject).not_to be_valid
        end
      end

      context "when the question is sorting" do
        let(:question_type) { "sorting" }

        it "is valid if all options checked" do
          subject.choices = [
            { "answer_option_id" => "1", "body" => "foo" },
            { "answer_option_id" => "2", "body" => "bar" },
            { "answer_option_id" => "3", "body" => "baz" }
          ]

          expect(subject).to be_valid
        end

        it "is not valid if not all options checked" do
          subject.choices = [
            { "answer_option_id" => "1", "body" => "foo" },
            { "answer_option_id" => "2", "body" => "bar" }
          ]

          expect(subject).not_to be_valid
        end
      end
    end
  end
end
