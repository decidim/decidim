# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe ResponseChoice do
      subject { response_choice }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question_type) { "single_option" }
      let(:question) { create(:questionnaire_question, questionnaire:, question_type:) }
      let(:response_options) { create_list(:response_option, 3, question:) }
      let(:response_option) { response_options.first }
      let(:matrix_rows) { create_list(:question_matrix_row, 3, question:) }
      let(:matrix_row) { matrix_rows.first }
      let(:response) { create(:response, question:, questionnaire:) }
      let(:response_choice) { build(:response_choice, response:, response_option:, matrix_row:) }

      it { is_expected.to be_valid }

      it "has an association of response" do
        expect(subject.response).to eq(response)
      end

      it "has an association of response_option" do
        expect(subject.response_option).to eq(response_option)
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
