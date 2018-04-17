# frozen_string_literal: true

require "spec_helper"

describe "Question embeds", type: :system do
  let(:question) { create(:question) }

  context "when visiting the embed page for a question" do
    before do
      switch_to_host(question.organization.host)
      visit "#{decidim_consultations.question_path(question)}/embed"
    end

    it "renders the page correctly" do
      expect(page).to have_i18n_content(question.title)
      expect(page).to have_content(question.organization.name)
    end
  end
end
