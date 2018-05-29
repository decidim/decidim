# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SurveyUserAnswersSerializer do
      subject do
        described_class.new(survey.answers)
      end

      let!(:survey) { create(:survey) }
      let!(:user) { create(:user, organization: survey.component.organization) }
      let!(:survey_questions) { create_list :survey_question, 3, survey: survey }
      let!(:survey_answers) do
        survey_questions.map do |question|
          create :survey_answer, survey: survey, question: question, user: user
        end
      end

      let!(:multichoice_survey_question) { create :survey_question, survey: survey, question_type: "multiple_option" }
      let!(:multichoice_answer_options) { create_list :survey_answer_option, 2, question: multichoice_survey_question }
      let!(:multichoice_answer) do
        create :survey_answer, survey: survey, question: multichoice_survey_question, user: user, body: nil
      end
      let!(:multichoice_answer_choices) do
        multichoice_answer_options.map do |answer_option|
          create :survey_answer_choice, answer: multichoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
        end
      end

      let!(:singlechoice_survey_question) { create :survey_question, survey: survey, question_type: "single_option" }
      let!(:singlechoice_answer_options) { create_list :survey_answer_option, 2, question: multichoice_survey_question }
      let!(:singlechoice_answer) do
        create :survey_answer, survey: survey, question: singlechoice_survey_question, user: user, body: nil
      end
      let!(:singlechoice_answer_choice) do
        answer_option = singlechoice_answer_options.first
        create :survey_answer_choice, answer: singlechoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "includes the answer for each question" do
          survey_questions.each_with_index do |question, idx|
            expect(serialized).to include(
              "#{idx + 1}. #{translated(question.body, locale: I18n.locale)}" => survey_answers[idx].body
            )
          end

          expect(serialized).to include(
            "4. #{translated(multichoice_survey_question.body, locale: I18n.locale)}" => multichoice_answer_choices.map(&:body)
          )

          expect(serialized).to include(
            "5. #{translated(singlechoice_survey_question.body, locale: I18n.locale)}" => [singlechoice_answer_choice.body]
          )
        end
      end
    end
  end
end
