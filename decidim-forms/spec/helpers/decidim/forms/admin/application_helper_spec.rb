# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::Admin::ApplicationHelper do
  let(:questionnaire) { create(:questionnaire) }
  let(:question) { create(:questionnaire_question, questionnaire:) }
  let(:condition_question) { create(:questionnaire_question, questionnaire:) }
  let(:response_option) { create(:response_option, question:) }
  let(:matrix_row) { create(:question_matrix_row, question:) }
  let(:display_condition) { create(:display_condition, question:, condition_question:) }

  describe "#tabs_id_for_question" do
    it "returns the correct tab id" do
      id = helper.tabs_id_for_question(question)
      expect(id).to eq("questionnaire_question_#{question.to_param}")
    end
  end

  describe "#tabs_id_for_question_response_option" do
    it "returns the correct tab id" do
      id = helper.tabs_id_for_question_response_option(question, response_option)
      expect(id).to eq("questionnaire_question_#{question.to_param}_response_option_#{response_option.to_param}")
    end
  end

  describe "#tabs_id_for_question_matrix_row" do
    it "returns the correct tab id" do
      id = helper.tabs_id_for_question_matrix_row(question, matrix_row)
      expect(id).to eq("questionnaire_question_#{question.to_param}_matrix_row_#{matrix_row.to_param}")
    end
  end

  describe "#tabs_id_for_question_display_condition" do
    it "returns the correct tab id" do
      id = helper.tabs_id_for_question_display_condition(question, display_condition)
      expect(id).to eq("questionnaire_question_#{question.to_param}_display_condition_#{display_condition.to_param}")
    end
  end
end
