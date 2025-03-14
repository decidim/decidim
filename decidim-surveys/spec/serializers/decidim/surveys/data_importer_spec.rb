# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe DataImporter do
    describe "#import" do
      subject do
        described_class.new(component).import(as_json, user)
      end

      let(:user) { create(:user) }
      let!(:original_questionnaire) { create(:questionnaire, :with_questions) }
      let!(:survey) { create(:survey, questionnaire: original_questionnaire) }
      let(:component) { survey.component }

      let(:as_json) do
        questionnaire_attrs = original_questionnaire.attributes
        questions = []
        original_questionnaire.questions.order(:position).each do |q|
          question_attrs = q.attributes
          response_options = q.response_options.map(&:attributes)
          question_attrs[:response_options] = response_options
          question_attrs = question_attrs.reject { |key, _value| key.ends_with?("_count") }
          questions << question_attrs
        end
        questionnaire_attrs[:questions] = questions
        [{
          id: rand(99_999),
          questionnaire: questionnaire_attrs
        }]
      end

      describe "#import" do
        let!(:imported) { subject }

        it "imports survey" do
          expect(imported.size).to eq(1)
          imported_survey = imported.first
          expect(imported_survey).to be_a(Decidim::Surveys::Survey)
          expect(imported_survey).to be_persisted
          questionnaire = imported_survey.questionnaire
          expect(questionnaire).to be_a(Decidim::Forms::Questionnaire)

          attribs_to_ignore = %w(id updated_at created_at questionnaire_for_id published_at)
          expected_attrs = original_questionnaire.attributes.except(*attribs_to_ignore)
          actual_attrs = questionnaire.attributes.except(*attribs_to_ignore)
          expect(actual_attrs.delete("published_at")).to be_nil
          expect(actual_attrs).to eq(expected_attrs)

          imported_questions_should_eq_serialized(questionnaire.questions)
        end
      end

      private

      def imported_questions_should_eq_serialized(imported_questions)
        original_questions = original_questionnaire.questions
        expect(imported_questions.size).to eq(original_questions.size)

        imported_questions.zip(original_questions).each do |imported, original|
          expect(imported.position).to eq(original.position)
          expect(imported.question_type).to eq(original.question_type)
          expect(imported.mandatory).to eq(original.mandatory)
          expect(imported.body).to eq(original.body)
          expect(imported.description).to eq(original.description)
          expect(imported.max_choices).to eq(original.max_choices)
          imported_question_options_should_eq_serialized(imported.response_options, original.response_options)
        end
      end

      def imported_question_options_should_eq_serialized(imported_response_options, original_response_options)
        expect(imported_response_options.size).to eq(original_response_options.size)
        imported_response_options.zip(original_response_options).each do |imported, original|
          expect(imported.body).to eq(original.body)
          expect(imported.free_text).to eq(original.free_text)
        end
      end
    end
  end
end
