# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    module Admin
      describe QuestionnaireAnswersHelper do
        describe "questionnaire_answer_body" do
          let!(:questionnaire) { create(:questionnaire) }

          context "when answer has a body" do
            let(:answer) { create(:answer) }

            it "Returns the answer body" do
              expect(helper.questionnaire_answer_body(answer)).to eq(answer.body)
            end
          end

          context "when answer has no selected choices" do
            let!(:question) { create :questionnaire_question, questionnaire: questionnaire, question_type: Decidim::Forms::Question::TYPES.fourth }
            let!(:answer_option) { create :answer_option, question: question }
            let!(:answer) { create :answer, questionnaire: questionnaire, question: question, body: nil }

            it "Returns '-'" do
              expect(helper.questionnaire_answer_body(answer)).to eq("-")
            end
          end

          context "when answer has selected choices" do
            it "Returns the choices' body separated by a comma"
          end
        end

        describe "questionnaire_participant_status" do
          context "when user is registered" do
            let(:registered) { true }

            it "Returns 'Registered'" do
              expect(helper.questionnaire_participant_status(registered)).to eq("Registered")
            end
          end

          context "when user is unregistered" do
            let(:registered) { false }
            
            it "Returns 'Unregistered'" do
              expect(helper.questionnaire_participant_status(registered)).to eq("Unregistered")
            end
          end
        end
        
        describe "display_percentage" do
          context "when given a number " do
            let(:number) { 84.64 }

            it "displays the number formatted as percentage with no decimals" do
              expect(helper.display_percentage(number)).to eq("85%")
            end
          end
        end
      end
    end
  end
end
