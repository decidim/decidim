# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Forms::Admin::QuestionnaireAnswerPresenter, type: :helper do
    subject { described_class.new(answer:) }

    let!(:questionnaire) { create :questionnaire }
    let!(:answer) { create(:answer, questionnaire:) }

    describe "questionnaire_answer_body" do
      context "when answer has a body" do
        before do
          answer.body = "abc"
        end

        it "Returns the answer body" do
          expect(subject.body).to eq(answer.body)
        end
      end

      context "when answer has no selected choices" do
        let!(:question) { create :questionnaire_question, question_type: "multiple_option" }

        before do
          answer.body = nil
        end

        it "Returns '-'" do
          expect(subject.body).to eq("-")
        end
      end

      context "when answer has one selected choice" do
        let!(:question) { create :questionnaire_question, questionnaire:, question_type: "single_option" }
        let!(:answer) { create(:answer, questionnaire:, question:, body: nil) }
        let!(:answer_option) { create :answer_option, question: }
        let!(:answer_choice) { create :answer_choice, answer:, answer_option:, body: translated(answer_option.body, locale: I18n.locale) }

        context "when it is a single_option question" do
          it "Returns the choice's body" do
            expect(subject.body).to eq("<li>#{answer_choice.body}</li>")
          end
        end

        context "when it is a multiple_option question" do
          let!(:question) { create :questionnaire_question, questionnaire:, question_type: "multiple_option" }

          it "Returns the choice's body as a <li> element inside a <ul>" do
            expect(subject.body).to eq("<ul><li>#{answer_choice.body}</li></ul>")
          end
        end
      end

      context "when answer has many selected choices" do
        let!(:answer) { create(:answer, body: nil) }
        let!(:answer_option1) { create :answer_option, question: answer.question }
        let!(:answer_option2) { create :answer_option, question: answer.question }
        let!(:answer_choice1) { create :answer_choice, answer:, answer_option: answer_option1, body: translated(answer_option1.body, locale: I18n.locale) }
        let!(:answer_choice2) { create :answer_choice, answer:, answer_option: answer_option2, body: translated(answer_option2.body, locale: I18n.locale) }

        it "Returns the choices wrapped in <li> elements inside a <ul>" do
          expect(subject.body).to eq("<ul><li>#{answer_choice1.body}</li><li>#{answer_choice2.body}</li></ul>")
        end

        context "and free text is enabled on answer options" do
          let!(:answer_option1) { create :answer_option, :free_text_enabled }
          let!(:answer_option2) { create :answer_option, :free_text_enabled }

          it "returns the choices and question wrapped in <li> elements inside a <ul>" do
            expect(subject.body).to eq("<ul><li>#{answer_option1.translated_body}</li><li>#{answer_option2.translated_body}</li></ul>")
          end
        end
      end

      context "when the answer has an attachment" do
        let!(:answer) { create(:answer, body: nil) }
        let!(:attachment) { create(:attachment, :with_image, attached_to: answer) }

        it "returns the download attachment link" do
          expect(subject.body).to eq(%(<ul><li><a target="_blank" rel="noopener noreferrer" href="#{attachment.url}"><span>#{translated(attachment.title)}</span> <small>jpeg 105 KB</small></a></li></ul>))
        end

        context "when the attachment does not have a title" do
          let!(:attachment) { create(:attachment, :with_image, attached_to: answer, title: {}, description: {}) }

          it "returns the download attachment link" do
            expect(subject.body).to eq(%(<ul><li><a target="_blank" rel="noopener noreferrer" href="#{attachment.url}"><span>Download attachment</span> <small>jpeg 105 KB</small></a></li></ul>))
          end
        end
      end
    end
  end
end
