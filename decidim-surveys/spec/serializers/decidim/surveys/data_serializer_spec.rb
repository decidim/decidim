# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe DataSerializer do
    describe "#serialize" do
      subject do
        described_class.new(survey.component)
      end

      let!(:questionnaire) { build(:questionnaire, :with_questions) }
      let!(:survey) { create(:survey, questionnaire:) }

      let(:serialized_surveys) { subject.serialize }

      it "serializes questionnaire" do
        expect(serialized_surveys.count).to eq(1)
        serialized_survey = serialized_surveys.first
        expect(serialized_survey[:id]).to eq(survey.id)

        serialized_questionnaire = serialized_survey[:questionnaire]
        expect(serialized_questionnaire[:title]).to eq(questionnaire.title)
        expect(serialized_questionnaire[:description]).to eq(questionnaire.description)
        expect(serialized_questionnaire[:tos]).to eq(questionnaire.tos)
        expect(serialized_questionnaire[:questionnaire_for_type]).to eq(survey.class.name)
        expect(serialized_questionnaire[:questionnaire_for_id]).to eq(survey.id)
        expect(serialized_questionnaire[:published_at]).to eq(questionnaire.published_at)

        questions_should_be_as_expected(questionnaire.questions.order(:position), serialized_questionnaire[:questions])
      end

      def questions_should_be_as_expected(questions, serializeds)
        expect(serializeds.size).to eq(3)
        num_expected_answers_list = [0, 0, 3]
        serializeds.zip(questions, num_expected_answers_list) do |serialized, question, num_expected_answers|
          expect(serialized[:id]).to eq(question.id)
          expect(serialized[:decidim_questionnaire_id]).to eq(question.decidim_questionnaire_id)
          expect(serialized[:position]).to eq(question.position)
          expect(serialized[:question_type]).to eq(question.question_type)
          expect(serialized[:mandatory]).to eq(question.mandatory)
          expect(serialized[:body]).to eq(question.body)
          expect(serialized[:description]).to eq(question.description)
          expect(serialized[:max_choices]).to eq(question.max_choices)

          options_should_be_as_expected(question.answer_options.order(:id), serialized[:answer_options], num_expected_answers)
        end
      end

      def options_should_be_as_expected(answer_options, serializeds, num_expected)
        expect(serializeds.size).to eq(num_expected)
        serializeds.zip(answer_options) do |serialized, option|
          expect(serialized[:id]).to eq(option.id)
          expect(serialized[:decidim_question_id]).to eq(option.decidim_question_id)
          expect(serialized[:body]).to eq(option.body)
          expect(serialized[:free_text]).to eq(option.free_text)
        end
      end
    end
  end
end
