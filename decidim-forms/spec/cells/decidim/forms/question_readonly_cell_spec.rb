# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionReadonlyCell, type: :cell do
  controller Decidim::PagesController

  subject { cell("decidim/forms/question_readonly", model) }

  let(:question) { create :questionnaire_question }
  let(:separator) { create :questionnaire_question, :separator }
  let(:title_and_description) { create :questionnaire_question, :title_and_description }
  let(:model) { question }

  context "when using a separator" do
    let(:model) { separator }

    it "doesn't render anything" do
      expect(subject.show.to_s).to be_empty
    end
  end

  context "when using a title-and-description" do
    it "renders the title-and-description body" do
      expect(subject.call).to have_content(translated(model.body))
    end

    it "renders the title-and-description type" do
      translated_question_type = I18n.t(model.question_type, scope: "decidim.forms.question_types")
      expect(subject.call).to have_content(translated_question_type)
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
  end
end
