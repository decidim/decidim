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
            expect(helper.chart_for_question(question.id)).to have_text("ColumnChart")
          end
        end

        context "when the question type is multiple_option" do
          let(:question) { create(:questionnaire_question, question_type: "multiple_option") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_text("ColumnChart")
          end

          context "and the responses select more than one option" do
            let(:questionnaire) { question.questionnaire }
            let!(:option_a) { create(:response_option, question:, body: { "en" => "Option A" }) }
            let!(:option_b) { create(:response_option, question:, body: { "en" => "Option B" }) }
            let!(:option_c) { create(:response_option, question:, body: { "en" => "Option C" }) }

            before do
              # A response selecting the three options at once.
              response1 = create(:response, questionnaire:, question:)
              [option_a, option_b, option_c].each do |response_option|
                create(:response_choice, response: response1, response_option:, matrix_row: nil)
              end

              # And a response for the first option and another one for the last option.
              response2 = create(:response, questionnaire:, question:)
              [option_a, option_c].each do |response_option|
                create(:response_choice, response: response2, response_option:, matrix_row: nil)
              end
            end

            it "counts every selected option, not the combination of options of each response" do
              expect(helper).to receive(:column_chart).with({ "Option A" => 2, "Option B" => 1, "Option C" => 2 }, download: true)

              helper.chart_for_question(question.id)
            end
          end
        end

        context "when the question type is sorting" do
          let(:question) { create(:questionnaire_question, question_type: "sorting") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_text("BarChart")
          end
        end

        context "when the question type is matrix_single" do
          let(:question) { create(:questionnaire_question, question_type: "matrix_single") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_text("ColumnChart")
          end
        end

        context "when the question type is matrix_multiple" do
          let(:question) { create(:questionnaire_question, question_type: "matrix_multiple") }

          it "returns the chart code" do
            expect(helper.chart_for_question(question.id)).to have_text("ColumnChart")
          end
        end
      end
    end
  end
end
