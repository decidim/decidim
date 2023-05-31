# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim
  module Forms
    module Admin
      describe QuestionForm do
        subject do
          described_class.from_params(
            question: attributes
          ).with_context(current_organization: questionable.organization)
        end

        let!(:questionable) { create(:dummy_resource) }
        let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }
        let!(:position) { 0 }
        let!(:question_type) { Decidim::Forms::Question::TYPES.first }
        let!(:max_characters) { 45 }

        let(:deleted) { "false" }
        let(:attributes) do
          {
            body_en: "Body en",
            body_ca: "Body ca",
            body_es: "Body es",
            question_type:,
            max_characters:,
            position:,
            deleted:
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the position is not present" do
          let!(:position) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the question_type is not known" do
          let!(:question_type) { "foo" }

          it { is_expected.not_to be_valid }
        end

        context "when the question has no answer options" do
          it "is invalid if max_choices present" do
            attributes[:max_choices] = 1

            expect(subject).not_to be_valid
          end
        end

        context "when the max_characters is less than 0" do
          let!(:max_characters) { -1 }

          it { is_expected.not_to be_valid }
        end

        context "when the question has no matrix rows" do
          it "is valid if question type is not matrix_single or matrix_multiple" do
            attributes[:question_type] = "short_answer"
            expect(subject).to be_valid
          end

          it "is invalid if question type is matrix_single" do
            attributes[:question_type] = "matrix_single"
            expect(subject).not_to be_valid
          end

          it "is invalid if question type is matrix_multiple" do
            attributes[:question_type] = "matrix_multiple"
            expect(subject).not_to be_valid
          end
        end

        context "when the question has answer options" do
          let!(:question_type) { "multiple_option" }

          it "is valid when max_choices under the number of options" do
            attributes[:max_choices] = 3
            attributes[:answer_options] = {
              "0" => { "body" => { "en" => "A" } },
              "1" => { "body" => { "en" => "B" } },
              "2" => { "body" => { "en" => "C" } }
            }

            expect(subject).to be_valid
          end

          it "is invalid when max_choices over the number of options" do
            attributes[:max_choices] = 4
            attributes[:answer_options] = {
              "0" => { "body" => { "en" => "A" } },
              "1" => { "body" => { "en" => "B" } },
              "2" => { "body" => { "en" => "C" } }
            }

            expect(subject).not_to be_valid
          end

          it "is valid when max choices under the number of options" do
            attributes[:max_choices] = 2
            attributes[:answer_options] = {
              "0" => { "body" => { "en" => "A" } },
              "1" => { "body" => { "en" => "B" } },
              "2" => { "body" => { "en" => "C" } }
            }

            expect(subject).to be_valid
          end
        end

        context "when the body is missing a locale translation" do
          before do
            attributes[:body_en] = ""
          end

          context "when the question is not deleted" do
            let(:deleted) { "false" }

            it { is_expected.not_to be_valid }
          end

          context "when the question is deleted" do
            let(:deleted) { "true" }

            it { is_expected.to be_valid }
          end
        end

        it_behaves_like "form to param", default_id: "questionnaire-question-id"

        describe "#matrix_rows_by_position" do
          let!(:question_type) { "single_option" }
          let(:matrix_rows) do
            {
              "1" => { "body" => { "en" => "Matrix row 1" }, "deleted" => "false" },
              "2" => { "body" => { "en" => "Matrix row 2" }, "deleted" => "false" },
              "3" => { "body" => { "en" => "Matrix row 3" }, "deleted" => "false" }
            }
          end

          before do
            attributes.merge!("matrix_rows" => matrix_rows)
          end

          context "when all rows are new" do
            it "positions are setted by order of reception" do
              matrix_rows_by_position = subject.matrix_rows_by_position
              (1..3).each do |idx|
                question_matrix_row_form = matrix_rows_by_position[idx - 1]
                expect(question_matrix_row_form.body["en"]).to eq(matrix_rows[idx.to_s]["body"]["en"])
              end
            end
          end

          context "when all rows already existed" do
            before do
              matrix_rows.each_pair do |key, row|
                row["id"] = key
                row["position"] = key
              end
            end

            it "keeps positions even when in different by order of reception" do
              matrix_rows_by_position = subject.matrix_rows_by_position
              (0..2).each do |idx|
                question_matrix_row_form = matrix_rows_by_position[idx]
                expect(question_matrix_row_form.body["en"]).to eq(matrix_rows[(idx + 1).to_s]["body"]["en"])
                expect(question_matrix_row_form.position).to eq(matrix_rows[(idx + 1).to_s]["position"].to_i)
              end
            end
          end

          context "when mixing existing and new rows" do
            before do
              matrix_rows.merge!({
                                   "4" => { "body" => { "en" => "Matrix row 4" }, "position" => "2", "deleted" => "false" },
                                   "5" => { "body" => { "en" => "Matrix row 5" }, "position" => "3", "deleted" => "false" },
                                   "7" => { "body" => { "en" => "Matrix row 7" }, "position" => "5", "deleted" => "false" },
                                   "6" => { "body" => { "en" => "Matrix row 6" }, "position" => "4", "deleted" => "false" },
                                   "8" => { "body" => { "en" => "Matrix row 8" }, "position" => "1", "deleted" => "false" }
                                 })
            end

            it "keeps positions of existing rows and moves all new rows to the end of the array" do
              matrix_rows_by_position = subject.matrix_rows_by_position

              # first five rows are the already existing ordered by position
              %w(8 4 5 6 7).each_with_index do |key, idx|
                question_matrix_row_form = matrix_rows_by_position[idx]
                expect(question_matrix_row_form.body["en"]).to eq(matrix_rows[key]["body"]["en"])
                expect(question_matrix_row_form.position).to eq(matrix_rows[key]["position"].to_i)
              end

              # at the end the new rows (no position attribute) by order of reception
              (5..7).each do |idx|
                question_matrix_row_form = matrix_rows_by_position[idx]
                expect(question_matrix_row_form.body["en"]).to eq(matrix_rows[(idx - 4).to_s]["body"]["en"])
                expect(question_matrix_row_form.position).to be_nil
              end
            end
          end
        end
      end
    end
  end
end
