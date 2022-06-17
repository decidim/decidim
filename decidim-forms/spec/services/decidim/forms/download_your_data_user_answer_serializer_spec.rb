# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe DownloadYourDataUserAnswersSerializer do
      include Decidim::TranslationsHelper

      subject do
        described_class.new(questionnaire.answers.first)
      end

      let!(:questionnaire) { create(:questionnaire) }
      let!(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        context "when question is files" do
          let!(:question) { create :questionnaire_question, questionnaire:, question_type: :files }
          let!(:answer) { create :answer, :with_attachments, questionnaire:, question:, user: }

          it "includes the answer id" do
            expect(serialized).to include(id: answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: answer.user.email)
            )
          end

          it "includes the questionnaire information" do
            expect(serialized[:questionnaire]).to(
              include(id: questionnaire.id)
            )
            expect(serialized[:questionnaire]).to(
              include(title: translated_attribute(questionnaire.title))
            )
            expect(serialized[:questionnaire]).to(
              include(description: translated_attribute(questionnaire.description))
            )
            expect(serialized[:questionnaire]).to(
              include(tos: translated_attribute(questionnaire.tos))
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(question.description))
            )
          end

          it "includes the answer" do
            expect(serialized).to include(answer: answer.attachments.map(&:url))
          end
        end

        context "when question is shortanswer" do
          let!(:question) { create :questionnaire_question, questionnaire: }
          let!(:answer) { create :answer, questionnaire:, question:, user: }

          it "includes the answer id" do
            expect(serialized).to include(id: answer.id)
          end

          it "includes the user" do
            expect(serialized[:user]).to(
              include(name: answer.user.name)
            )
            expect(serialized[:user]).to(
              include(email: answer.user.email)
            )
          end

          it "includes the questionnaire information" do
            expect(serialized[:questionnaire]).to(
              include(id: questionnaire.id)
            )
            expect(serialized[:questionnaire]).to(
              include(title: translated_attribute(questionnaire.title))
            )
            expect(serialized[:questionnaire]).to(
              include(description: translated_attribute(questionnaire.description))
            )
            expect(serialized[:questionnaire]).to(
              include(tos: translated_attribute(questionnaire.tos))
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(question.description))
            )
          end

          it "includes the answer" do
            expect(serialized).to include(answer: answer.body)
          end
        end

        context "when question is multiple choice" do
          let!(:multichoice_question) { create :questionnaire_question, questionnaire:, question_type: "multiple_option" }
          let!(:multichoice_answer_options) { create_list :answer_option, 2, question: multichoice_question }
          let!(:multichoice_answer) do
            create :answer, questionnaire:, question: multichoice_question, user:, body: nil
          end
          let!(:multichoice_answer_choices) do
            multichoice_answer_options.map do |answer_option|
              create :answer_choice, answer: multichoice_answer, answer_option:, body: answer_option.body[I18n.locale.to_s]
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
              include(id: multichoice_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(multichoice_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(multichoice_question.description))
            )
          end

          it "includes the answers" do
            expect(serialized).to include(answer: multichoice_answer_choices.map(&:body))
          end
        end

        context "when question is single choice" do
          let!(:singlechoice_question) { create :questionnaire_question, questionnaire:, question_type: "single_option" }
          let!(:singlechoice_answer_options) { create_list :answer_option, 2, question: singlechoice_question }
          let!(:singlechoice_answer) do
            create :answer, questionnaire:, question: singlechoice_question, user:, body: nil
          end
          let!(:singlechoice_answer_choice) do
            answer_option = singlechoice_answer_options.first
            create :answer_choice, answer: singlechoice_answer, answer_option:, body: answer_option.body[I18n.locale.to_s]
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
              include(id: singlechoice_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(singlechoice_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(singlechoice_question.description))
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
