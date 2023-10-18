# frozen_string_literal: true

require "spec_helper"

describe "User answers the initiative", type: :system do
  include_context "when admins initiative"

  def submit_and_validate(message)
    within "[data-content]" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout(message)
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

      submit_and_validate("The initiative has been successfully updated")
    end

    context "when initiative is in published state" do
      before do
        initiative.published!
      end

      context "and signature dates are editable" do
        it "can be edited in answer" do
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

          submit_and_validate("The initiative has been successfully updated")
        end

        context "when dates are invalid" do
          it "returns an error message" do
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

              fill_in :initiative_signature_start_date, with: 1.month.since(initiative.signature_end_date)
            end

            submit_and_validate("An error has occurred")
            expect(page).to have_current_path decidim_admin_initiatives.edit_initiative_answer_path(initiative)
          end
        end
      end
    end

    context "when initiative is in validating state" do
      before do
        initiative.validating!
      end

      it "signature dates are not displayed" do
        page.find(".action-icon--answer").click

        within ".edit_initiative_answer" do
          expect(page).not_to have_css("#initiative_signature_start_date")
          expect(page).not_to have_css("#initiative_signature_end_date")
        end
      end
    end
  end
end
