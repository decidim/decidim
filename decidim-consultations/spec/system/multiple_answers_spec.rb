# frozen_string_literal: true

require "spec_helper"

describe "Multiple Answers Question", type: :system do
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, :active, organization: organization) }
  let(:question) { create :question, :multiple, :published, consultation: consultation }
  let(:user) { create :user, :confirmed, organization: organization }

  context "and guest user" do
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
      expect(page).to have_button(id: "vote_button")
      expect(page).not_to have_link(id: "multivote_button")
    end

    it "Page do not contains an unvote button" do
      expect(page).not_to have_button(id: "unvote_button")
    end
  end

  context "and authenticated user" do
    # let!(:response) { create :response, question: question }

    context "and never voted before" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_consultations.question_path(question)
      end

      it "Page contains a vote button" do
        expect(page).to have_link(id: "multivote_button")
      end

      # it "unvote button appears after voting" do
      #   click_link(id: "vote_button")
      #   click_button translated(response.title)
      #   click_button "Confirm"
      #   expect(page).to have_button(id: "unvote_button")
      # end

    end
  end

end
