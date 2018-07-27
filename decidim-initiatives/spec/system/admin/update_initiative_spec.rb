# frozen_string_literal: true

require "spec_helper"

describe "User prints the initiative", type: :system do
  include_context "when admins initiative"

  def submit_and_validate
    find("*[type=submit]").click

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end
  end

  context "when initiative update" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    it "Updates published initiative data" do
      page.find(".action-icon--edit").click
      within ".edit_initiative" do
        fill_in :initiative_hashtag, with: "#hashtag"
      end
      submit_and_validate
    end

    context "when initiative is in accepted state" do
      before do
        initiative.accepted!
      end

      it "updates accepted initiative data" do
        page.find(".action-icon--edit").click
        within ".edit_initiative" do
          fill_in_i18n_editor(
            :initiative_answer,
            "#initiative-answer-tabs",
            ca: "Alguna resposta",
            en: "Some answer",
            es: "Alguna respuesta"
          )
          fill_in :initiative_answer_url, with: "http://meta.decidim.org"
        end
        submit_and_validate
      end
    end
  end
end
