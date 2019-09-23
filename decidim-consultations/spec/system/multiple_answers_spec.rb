# frozen_string_literal: true

require "spec_helper"

describe "Multiple Answers Question", type: :system do
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, :published, organization: organization) }
  let(:question) { create :question, :multiple, :published, consultation: consultation }

  context "when shows question information" do
    before do
      switch_to_host(organization.host)
      visit decidim_consultations.question_path(question)
    end

    it "Shows the basic question data" do
      expect(page).to have_i18n_content(question.promoter_group)
      expect(page).to have_i18n_content(question.scope.name)
      expect(page).to have_i18n_content(question.participatory_scope)
      expect(page).to have_i18n_content(question.question_context)

      expect(page).not_to have_i18n_content(question.what_is_decided)
    end

    it "Page contains a vote button" do
      expect(page).to have_link(id: "vote_button")
    end

    # it "unvote button appears after voting" do
    #   click_link(id: "vote_button")
    #   click_button translated(response.title)
    #   click_button "Confirm"
    #   expect(page).to have_button(id: "unvote_button")
    # end
  end

end
