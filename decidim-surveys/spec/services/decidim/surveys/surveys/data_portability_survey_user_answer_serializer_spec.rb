# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe DataPortabilitySurveyUserAnswersSerializer do
      include Decidim::TranslationsHelper

      subject do
        described_class.new(survey.answers.first)
      end

      let!(:survey) { create(:survey) }
      let!(:user) { create(:user, organization: survey.component.organization) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        context "when survey_question is shortanswer" do
          let!(:survey_question) { create :survey_question, survey: survey }
          let!(:survey_answer) { create :survey_answer, survey: survey, question: survey_question, user: user }

          it "includes the answer id" do
            expect(serialized).to include(id: survey_answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: survey_answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: survey_answer.user.email)
            )
          end

          it "includes the survey information" do
            expect(serialized[:survey]).to(
              include(id: survey.id)
            )
            expect(serialized[:survey]).to(
              include(title: translated_attribute(survey.title))
            )
            expect(serialized[:survey]).to(
              include(description: translated_attribute(survey.description))
            )
            expect(serialized[:survey]).to(
              include(tos: translated_attribute(survey.tos))
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: survey_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(survey_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(survey_question.description))
            )
          end

          it "includes the answer " do
            expect(serialized).to include(answer: survey_answer.body)
          end
        end

        context "when survey_question is multiple choice" do
          let!(:multichoice_survey_question) { create :survey_question, survey: survey, question_type: "multiple_option" }
          let!(:multichoice_answer_options) { create_list :survey_answer_option, 2, question: multichoice_survey_question }
          let!(:multichoice_answer) do
            create :survey_answer, survey: survey, question: multichoice_survey_question, user: user, body: nil
          end
          let!(:multichoice_answer_choices) do
            multichoice_answer_options.map do |answer_option|
              create :survey_answer_choice, answer: multichoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
            end
          end

          it "includes the answer id" do
            expect(serialized).to include(id: multichoice_answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: multichoice_answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: multichoice_answer.user.email)
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: multichoice_survey_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(multichoice_survey_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(multichoice_survey_question.description))
            )
          end

          it "includes the answers" do
            expect(serialized).to include(answer: multichoice_answer_choices.map(&:body))
          end
        end

        context "when survey_question is single choice" do
          let!(:singlechoice_survey_question) { create :survey_question, survey: survey, question_type: "single_option" }
          let!(:singlechoice_answer_options) { create_list :survey_answer_option, 2, question: singlechoice_survey_question }
          let!(:singlechoice_answer) do
            create :survey_answer, survey: survey, question: singlechoice_survey_question, user: user, body: nil
          end
          let!(:singlechoice_answer_choice) do
            answer_option = singlechoice_answer_options.first
            create :survey_answer_choice, answer: singlechoice_answer, answer_option: answer_option, body: answer_option.body[I18n.locale.to_s]
          end

          it "includes the answer id" do
            expect(serialized).to include(id: singlechoice_answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: singlechoice_answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: singlechoice_answer.user.email)
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: singlechoice_survey_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(singlechoice_survey_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(singlechoice_survey_question.description))
            )
          end

          it "includes the answers" do
            expect(serialized).to include(answer: [singlechoice_answer_choice.body])
          end
        end
      end
    end
  end
end
