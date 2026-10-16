# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Response do
      subject { response }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question) { create(:questionnaire_question, questionnaire:) }
      let(:response) { create(:response, questionnaire:, question:, user:) }

      it { is_expected.to be_valid }

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      it "has an association of user" do
        expect(subject.user).to eq(user)
      end

      describe "counter cache" do
        it "increments the questionnaire responses_count when a response is created" do
          expect do
            create(:response, questionnaire:, question:, user:)
          end.to change { questionnaire.reload.responses_count }.by(1)
        end

        it "decrements the questionnaire responses_count when a response is destroyed" do
          response

          expect do
            response.destroy!
          end.to change { questionnaire.reload.responses_count }.by(-1)
        end

        it "updates both questionnaires responses_count when a response is reassigned to another questionnaire" do
          other_questionnaire = create(:questionnaire, questionnaire_for: participatory_process)
          other_question = create(:questionnaire_question, questionnaire: other_questionnaire)

          response.update!(questionnaire: other_questionnaire, question: other_question)

          expect(questionnaire.reload.responses_count).to eq(0)
          expect(other_questionnaire.reload.responses_count).to eq(1)
        end

        context "with concurrent creations" do
          it_behaves_like "a concurrency safe counter cache" do
            let(:counter_parent) { questionnaire }
            let(:counter_column) { :responses_count }
            let(:counter_children) do
              item = question
              users = create_list(:user, 5, organization:)

              users.map do |respondent|
                ->(parent) { create(:response, questionnaire: parent, question: item, user: respondent) }
              end
            end
          end
        end
      end

      context "when the user does not belong to the same organization" do
        it "is not valid" do
          subject.user = create(:user)
          expect(subject).not_to be_valid
        end
      end

      context "when question does not belong to the questionnaire" do
        it "is not valid" do
          subject.question = create(:questionnaire_question)
          expect(subject).not_to be_valid
        end
      end

      describe "#text_value" do
        let(:response) { create(:response, questionnaire:, question: create(:questionnaire_question, questionnaire:, question_type:), body: "legacy", value:) }

        context "with a text question" do
          let(:question_type) { "long_response" }
          let(:value) { "hello" }

          it { expect(response.text_value).to eq("hello") }
        end

        context "with a value that is not a text" do
          let(:question_type) { "long_response" }
          let(:value) { [{ "option" => 1 }] }

          it { expect(response.text_value).to be_nil }
        end

        context "with a choice question" do
          let(:question_type) { "single_option" }
          let(:value) { { "option" => 1 } }

          it { expect(response.text_value).to be_nil }
        end
      end

      describe "#selections" do
        let(:response) { create(:response, questionnaire:, question: create(:questionnaire_question, questionnaire:, question_type:), body: nil, value:) }

        context "with a single option" do
          let(:question_type) { "single_option" }
          let(:value) { { "option" => 1, "text" => "mine" } }

          it { expect(response.selections).to eq([{ "option" => 1, "text" => "mine" }]) }
        end

        context "with a sorting" do
          let(:question_type) { "sorting" }
          let(:value) { [{ "option" => 3 }, { "option" => 1 }, { "option" => 2 }] }

          it { expect(response.selections).to eq([{ "option" => 3 }, { "option" => 1 }, { "option" => 2 }]) }
        end

        context "with a matrix single" do
          let(:question_type) { "matrix_single" }
          let(:value) { { "101" => { "option" => 1 } } }

          it { expect(response.selections).to eq([{ "option" => 1, "row" => 101 }]) }
        end

        context "with a matrix multiple" do
          let(:question_type) { "matrix_multiple" }
          let(:value) { { "101" => [{ "option" => 1 }], "102" => [{ "option" => 2 }, { "option" => 3, "text" => "mine" }] } }

          it "flattens the rows keeping the row id" do
            expect(response.selections).to eq([{ "option" => 1, "row" => 101 }, { "option" => 2, "row" => 102 }, { "option" => 3, "text" => "mine", "row" => 102 }])
          end
        end

        context "without a value" do
          let(:question_type) { "multiple_option" }
          let(:value) { nil }

          it { expect(response.selections).to eq([]) }
        end

        context "with a text question" do
          let(:question_type) { "short_response" }
          let(:value) { "hello" }

          it { expect(response.selections).to eq([]) }
        end

        context "with a value stored for another question type" do
          let(:question_type) { "matrix_multiple" }
          let(:value) { [{ "option" => 1 }] }

          it { expect(response.selections).to eq([]) }
        end
      end
    end
  end
end
