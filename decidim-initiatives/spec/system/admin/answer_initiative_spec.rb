# frozen_string_literal: true

require "spec_helper"

describe "User answers the initiative", type: :system do
  include_context "when admins initiative"

  def submit_and_validate
    find("*[type=submit]").click

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end
  end

  context "when user is author" do
    before do
      switch_to_host(organization.host)
      login_as author, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    it "answer is forbidden" do
      expect(page).to have_no_css(".action-icon--answer")

      visit decidim_admin_initiatives.edit_initiative_answer_path(initiative)

      expect(page).to have_content("You are not authorized")
    end
  end

  context "when user is admin" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    it "answer is allowed" do
      expect(page).to have_css(".action-icon--answer")
      page.find(".action-icon--answer").click

      within ".edit_initiative_answer" do
        fill_in_i18n_editor(
          :initiative_answer,
          "#initiative-answer-tabs",
          en: "An answer",
          es: "Una respuesta",
          ca: "Una resposta"
        )
      end

      submit_and_validate
    end

    context "when initiative is in published state" do
      before do
        initiative.published!
      end

      it "signature dates can be edited in answer" do
        page.find(".action-icon--answer").click

        within ".edit_initiative_answer" do
          fill_in_i18n_editor(
            :initiative_answer,
            "#initiative-answer-tabs",
            en: "An answer",
            es: "Una respuesta",
            ca: "Una resposta"
          )
          expect(page).to have_css("#initiative_signature_start_date")
          expect(page).to have_css("#initiative_signature_end_date")

          fill_in :initiative_signature_start_date, with: 1.day.ago
        end

        submit_and_validate
      end
    end

    context "when initiative is in validating state" do
      before do
        initiative.validating!
      end

      it "signature dates are not displayed" do
        page.find(".action-icon--answer").click

        within ".edit_initiative_answer" do
          expect(page).to have_no_css("#initiative_signature_start_date")
          expect(page).to have_no_css("#initiative_signature_end_date")
        end
      end
    end
  end
end
