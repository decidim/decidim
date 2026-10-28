# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe QuestionMatrixRow do
      subject { question_matrix_row }

      let(:questionnaire) { create(:questionnaire) }
      let(:question_type) { "matrix_single" }
      let(:question) { create(:questionnaire_question, questionnaire:, question_type:) }
      let(:question_matrix_row) { build(:question_matrix_row, question:) }

      it { is_expected.to be_valid }

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      it "uses the question's matrix_rows association as the inverse" do
        subject.save!

        expect(question.matrix_rows.first.question).to be(question)
      end

      it "has an association of response_options" do
        subject.response_options << create(:response_option, question:)
        subject.response_options << create(:response_option, question:)
        expect(subject.response_options.count).to eq(2)
      end

      it "has an association of choices" do
        response = create(:response, question:, questionnaire:)
        choices = create_list(:response_choice, 2, response:, matrix_row: question_matrix_row)

        expect(subject.choices).to match_array(choices)
      end

      it "uses the choices association as the inverse of the matrix row" do
        response = create(:response, question:, questionnaire:)
        create(:response_choice, response:, matrix_row: question_matrix_row)

        expect(question_matrix_row.choices.first.matrix_row).to be(question_matrix_row)
      end

      describe "#mandatory" do
        it "is delegated to question" do
          expect(subject.mandatory).to eq(question.mandatory)
        end
      end
    end
  end
end
