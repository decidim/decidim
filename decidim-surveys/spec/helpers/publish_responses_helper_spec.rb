# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe PublishResponsesHelper do
      describe "#question_response_is_publicable" do
        context "when the question type is unsupported" do
          let(:question_types) { %w(short_response long_response separator files) }

          it "returns false" do
            question_types.each do |question_type|
              expect(helper.question_response_is_publicable(question_type)).to be_falsey
            end
          end
        end

        context "when the question type is supported" do
          let(:question_types) { %w(single_option multiple_option sorting matrix_single matrix_multiple) }

          it "returns true" do
            question_types.each do |question_type|
              expect(helper.question_response_is_publicable(question_type)).to be_truthy
            end
          end
        end
      end

      describe "#chart_for_question" do
        context "when the question type is unsupported" do
          let(:question) { create(:questionnaire_question, question_type: "short_response") }

          it "returns a string with an error" do
            expect(helper.chart_for_question(question.id)).to eq("Unknown question type")
          end
        end

        context "when the question type is single_option" do
          let(:question) { create(:questionnaire_question, question_type: "single_option") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_content("ColumnChart")
          end
        end

        context "when the question type is multiple_option" do
          let(:question) { create(:questionnaire_question, question_type: "multiple_option") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_content("ColumnChart")
          end
        end

        context "when the question type is sorting" do
          let(:question) { create(:questionnaire_question, question_type: "sorting") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_content("BarChart")
          end
        end

        context "when the question type is matrix_single" do
          let(:question) { create(:questionnaire_question, question_type: "matrix_single") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_content("ColumnChart")
          end
        end

        context "when the question type is matrix_multiple" do
          let(:question) { create(:questionnaire_question, question_type: "matrix_multiple") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_content("ColumnChart")
          end
        end
      end
    end
  end
end
