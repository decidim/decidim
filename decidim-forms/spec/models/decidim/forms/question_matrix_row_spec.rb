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

      describe "#destroy" do
        let(:question_matrix_row) { create(:question_matrix_row, question:) }

        it "does not destroy the recorded choices" do
          response = create(:response, question:, questionnaire:)
          choice = create(:response_choice, response:, response_option: create(:response_option, question:), matrix_row: question_matrix_row)

          expect(question_matrix_row.destroy).to be(false)
          expect(question_matrix_row.errors[:base]).to include("Cannot delete record because dependent choices exist")
          expect(Decidim::Forms::ResponseChoice.exists?(choice.id)).to be(true)
        end

        it "is destroyed when it has no recorded choices" do
          expect(question_matrix_row.destroy).to be_truthy
          expect(Decidim::Forms::QuestionMatrixRow.exists?(question_matrix_row.id)).to be(false)
        end

        it "is destroyed when the loaded target still holds choices removed through the response" do
          response = create(:response, question:, questionnaire:)
          choice = create(:response_choice, response:, response_option: create(:response_option, question:), matrix_row: question_matrix_row)
          question_matrix_row.choices.to_a
          choice.destroy!

          expect(question_matrix_row.destroy).to be_truthy
        end
      end

      describe "#mandatory" do
        it "is delegated to question" do
          expect(subject.mandatory).to eq(question.mandatory)
        end
      end
    end
  end
end
