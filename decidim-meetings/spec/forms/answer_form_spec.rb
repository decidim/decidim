# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe AnswerForm do
      subject do
        described_class.from_model(answer).with_context(context)
      end

      let(:current_organization) { create(:organization) }
      let(:user) { create :user, organization: meeting_component.organization }
      let(:meeting_component) { create :meeting_component }
      let(:meeting) { create :meeting, component: meeting_component }
      let(:poll) { create :poll, meeting: }
      let(:questionnaire) { create :meetings_poll_questionnaire, questionnaire_for: poll }
      let!(:question) do
        create(
          :meetings_poll_question,
          questionnaire:,
          max_choices:
        )
      end
      let(:answer_options) { create_list(:meetings_poll_answer_option, 5, question:) }
      let!(:answer) { build(:meetings_poll_answer, user:, questionnaire:, question:) }

      let(:context) do
        {
          question_id: question.id
        }
      end
      let(:max_choices) { nil }

      let(:options) do
        [
          { "body" => Decidim::Faker::Localized.sentence },
          { "body" => Decidim::Faker::Localized.sentence },
          { "body" => Decidim::Faker::Localized.sentence }
        ]
      end

      context "when question type is multiple choice" do
        it "is not valid if choices are empty" do
          subject.choices = []
          expect(subject).not_to be_valid
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
    end
  end
end
