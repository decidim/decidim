# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Forms::Admin::QuestionnaireResponsePresenter, type: :helper do
    subject { described_class.new(response:) }

    let!(:questionnaire) { create(:questionnaire) }
    let!(:response) { create(:response, questionnaire:) }

    describe "questionnaire_response_body" do
      context "when response has a body" do
        before do
          response.body = "abc"
        end

        it "Returns the response body" do
          expect(subject.body).to eq(response.body)
        end
      end

      context "when response has no selected choices" do
        let!(:question) { create(:questionnaire_question, question_type: "multiple_option") }

        before do
          response.body = nil
        end

        it "Returns '-'" do
          expect(subject.body).to eq("-")
        end
      end

      context "when response has one selected choice" do
        let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "single_option") }
        let!(:response) { create(:response, questionnaire:, question:, body: nil) }
        let!(:response_option) { create(:response_option, question:) }
        let!(:response_choice) { create(:response_choice, response:, response_option:, body: translated(response_option.body, locale: I18n.locale)) }

        context "when it is a single_option question" do
          it "Returns the choice's body" do
            expect(subject.body).to eq("<li>#{response_choice.body}</li>")
          end
        end

        context "when it is a multiple_option question" do
          let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "multiple_option") }

          it "Returns the choice's body as a <li> element inside a <ul>" do
            expect(subject.body).to eq("<ul><li>#{response_choice.body}</li></ul>")
          end
        end
      end

      context "when response has many selected choices" do
        let!(:response) { create(:response, body: nil) }
        let!(:response_option1) { create(:response_option, question: response.question) }
        let!(:response_option2) { create(:response_option, question: response.question) }
        let!(:response_choice1) { create(:response_choice, response:, response_option: response_option1, body: translated(response_option1.body, locale: I18n.locale)) }
        let!(:response_choice2) { create(:response_choice, response:, response_option: response_option2, body: translated(response_option2.body, locale: I18n.locale)) }

        it "Returns the choices wrapped in <li> elements inside a <ul>" do
          expect(subject.body).to eq("<ul><li>#{response_choice1.body}</li><li>#{response_choice2.body}</li></ul>")
        end

        context "and free text is enabled on response options" do
          let!(:response_option1) { create(:response_option, :free_text_enabled) }
          let!(:response_option2) { create(:response_option, :free_text_enabled) }

          it "returns the choices and question wrapped in <li> elements inside a <ul>" do
            expect(subject.body).to eq("<ul><li>#{response_option1.translated_body}</li><li>#{response_option2.translated_body}</li></ul>")
          end
        end
      end

      context "when the response has an attachment" do
        let!(:response) { create(:response, body: nil) }
        let!(:attachment) { create(:attachment, :with_image, attached_to: response) }

        it "returns the download attachment link" do
          regexp = %r{^<ul><li>(<a target="_blank" rel="noopener noreferrer" href="([^"]+)">(((?!</a>).)*)</a>)</li></ul>}
          expect(subject.body).to match(regexp)

          match = subject.body.match(regexp)
          href = match[2]
          inner = match[3]

          expect(inner).to eq(%(<span>#{decidim_escape_translated(attachment.title)}</span> <small>jpeg 105 KB</small>))
          expect(href).to be_blob_url(attachment.file.blob)
        end

        context "when the attachment does not have a title" do
          let!(:attachment) { create(:attachment, :with_image, attached_to: response, title: {}, description: {}) }

          it "returns the download attachment link" do
            regexp = %r{^<ul><li><a target="_blank" rel="noopener noreferrer" href="([^"]+)"><span>Download attachment</span> <small>jpeg 105 KB</small></a></li></ul>$}
            expect(subject.body).to match(regexp)

            match = subject.body.match(regexp)
            href = match[1]

            expect(href).to be_blob_url(attachment.file.blob)
          end
        end
      end
    end
  end
end
