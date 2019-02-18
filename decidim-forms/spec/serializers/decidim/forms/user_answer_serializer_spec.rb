# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe UserAnswersSerializer do
      subject do
        described_class.new(questionnaire.answers)
      end

      let!(:questionable) { create(:dummy_resource) }
      let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }
      let!(:user) { create(:user, organization: questionable.organization) }
      let!(:questions) { create_list :questionnaire_question, 3, questionnaire: questionnaire }
      let!(:answers) do
        questions.map do |question|
          create :answer, questionnaire: questionnaire, question: question, user: user
        end
      end

      let!(:multichoice_question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "multiple_option" }
      let!(:multichoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
      let!(:multichoice_answer) do
        create :answer, questionnaire: questionnaire, question: multichoice_question, user: user, body: nil
      end
      let!(:multichoice_answer_choices) do
        multichoice_answer_options.map do |answer_option|
          create :answer_choice, answer: multichoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
        end
      end

      let!(:singlechoice_question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "single_option" }
      let!(:singlechoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
      let!(:singlechoice_answer) do
        create :answer, questionnaire: questionnaire, question: singlechoice_question, user: user, body: nil
      end
      let!(:singlechoice_answer_choice) do
        answer_option = singlechoice_answer_options.first
        create :answer_choice, answer: singlechoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s], custom_body: "Free text"
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "includes the answer for each question" do
          questions.each_with_index do |question, idx|
            expect(serialized).to include(
              "#{idx + 1}. #{translated(question.body, locale: I18n.locale)}" => answers[idx].body
            )
          end

          expect(serialized).to include(
            "4. #{translated(multichoice_question.body, locale: I18n.locale)}" => multichoice_answer_choices.map(&:body)
          )

          expect(serialized).to include(
            "5. #{translated(singlechoice_question.body, locale: I18n.locale)}" => ["Free text"]
          )
        end
      end
    end
  end
end
