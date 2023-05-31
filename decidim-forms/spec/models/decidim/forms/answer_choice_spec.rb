# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe AnswerChoice do
      subject { answer_choice }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question_type) { "single_option" }
      let(:question) { create(:questionnaire_question, questionnaire:, question_type:) }
      let(:answer_options) { create_list(:answer_option, 3, question:) }
      let(:answer_option) { answer_options.first }
      let(:matrix_rows) { create_list(:question_matrix_row, 3, question:) }
      let(:matrix_row) { matrix_rows.first }
      let(:answer) { create(:answer, question:, questionnaire:) }
      let(:answer_choice) { build(:answer_choice, answer:, answer_option:, matrix_row:) }

      it { is_expected.to be_valid }

      it "has an association of answer" do
        expect(subject.answer).to eq(answer)
      end

      it "has an association of answer_option" do
        expect(subject.answer_option).to eq(answer_option)
      end

      it "has an association of matrix_row" do
        expect(subject.matrix_row).to eq(matrix_row)
      end

      context "when the question type is a matrix type" do
        let(:question_type) { "matrix_multiple" }
        let(:matrix_row) { nil }

        it "is not valid without a matrix_row" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
