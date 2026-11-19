# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionReadonlyCell, type: :cell do
  controller Decidim::PagesController

  subject { cell("decidim/forms/question_readonly", model, indexed_items:) }

  let(:question) { create(:questionnaire_question) }
  let(:separator) { create(:questionnaire_question, :separator) }
  let(:title_and_description) { create(:questionnaire_question, :title_and_description) }
  let(:model) { question }
  let(:indexed_items) { [question.id + 1, question.id + 2, question.id] }

  context "when using a separator" do
    let(:model) { separator }

    it "does not render anything" do
      expect(subject.show.to_s).to be_empty
    end
  end

  context "when using a title-and-description" do
    let(:model) { title_and_description }

    it "renders the title-and-description body" do
      expect(subject.call).to have_content(translated(model.body))
    end

    it "renders the title-and-description description" do
      expect(subject.call).to have_text(decidim_sanitize(translated(model.description), strip_tags: true))
    end

    it "renders the title-and-description type" do
      translated_question_type = I18n.t(model.question_type, scope: "decidim.forms.question_types")
      expect(subject.call).to have_content(translated_question_type)
    end

    it "does not render the element with the response idx attribute" do
      expect(subject.call).to have_no_css("[data-response-idx]")
    end

    context "when the title contains a malicious script" do
      let(:payload) { "<script>alert('XSS');</script>" }
      let(:model) do
        create(:questionnaire_question, :title_and_description, skip_injection: true, body: { en: payload })
      end

      it "escapes the title instead of rendering the script" do
        expect(subject.call.to_s).not_to match(/<script>/i)
        expect(subject.call.to_s).to include("&lt;script&gt;")
        expect(subject.call).to have_text(payload)
      end
    end

    context "when the description contains a malicious script" do
      let(:payload) { "<script>alert('XSS');</script>" }
      let(:model) do
        create(:questionnaire_question, :title_and_description, skip_injection: true, description: { en: payload })
      end

      it "sanitizes the description instead of rendering the script" do
        expect(subject.call.to_s).not_to match(/<script>/i)
      end
    end
  end

  context "when using a question" do
    it "renders the question body" do
      expect(subject.call).to have_content(translated(question.body))
    end

    it "renders the question type" do
      translated_question_type = I18n.t(model.question_type, scope: "decidim.forms.question_types")
      expect(subject.call).to have_content(translated_question_type)
    end

    it "renders the element with the response idx attribute with the correct position" do
      expect(subject.call).to have_css("[data-response-idx='3']")
    end

    context "when the title contains a malicious script" do
      let(:payload) { "<script>alert('XSS');</script>" }
      let(:model) { create(:questionnaire_question, skip_injection: true, body: { en: payload }) }
      let(:indexed_items) { [model.id] }

      it "escapes the title instead of rendering the script" do
        expect(subject.call.to_s).not_to match(/<script>/i)
        expect(subject.call.to_s).to include("&lt;script&gt;")
        expect(subject.call).to have_text(payload)
      end
    end
  end
end
