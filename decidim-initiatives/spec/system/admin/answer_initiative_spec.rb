# frozen_string_literal: true

require "spec_helper"

describe "User answers the initiative" do
  include_context "when admins initiative"

  context "when user is admin" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    it "answer is allowed" do
      within("tr", text: translated(initiative.title)) do
        find("button[data-component='dropdown']").click
        click_on "Answer"
      end

      within ".edit_initiative_answer" do
        fill_in_i18n_editor(
          :initiative_answer,
          "#initiative-answer-tabs",
          en: "An answer",
          es: "Una respuesta",
          ca: "Una resposta"
        )
      end

      within "[data-content]" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("The initiative has been successfully updated")
    end

    context "when initiative is in published state" do
      before do
        initiative.open!
      end

      context "and signature dates are editable" do
        it "can be edited in answer" do
          within("tr", text: translated(initiative.title)) do
            find("button[data-component='dropdown']").click
            click_on "Answer"
          end

          within ".edit_initiative_answer" do
            fill_in_i18n_editor(
              :initiative_answer,
              "#initiative-answer-tabs",
              en: "An answer",
              es: "Una respuesta",
              ca: "Una resposta"
            )
            expect(page).to have_css("#initiative_signature_start_date_date")
            expect(page).to have_css("#initiative_signature_end_date_date")

            fill_in_datepicker :initiative_signature_start_date_date, with: 1.day.ago.strftime("%d/%m/%Y")
          end

          within "[data-content]" do
            find("*[type=submit]").click
          end

          expect(page).to have_admin_callout("The initiative has been successfully updated")
        end

        context "when dates are invalid" do
          it "returns an error message" do
            within("tr", text: translated(initiative.title)) do
              find("button[data-component='dropdown']").click
              click_on "Answer"
            end

            within ".edit_initiative_answer" do
              fill_in_i18n_editor(
                :initiative_answer,
                "#initiative-answer-tabs",
                en: "An answer",
                es: "Una respuesta",
                ca: "Una resposta"
              )
              expect(page).to have_css("#initiative_signature_start_date_date")
              expect(page).to have_css("#initiative_signature_end_date_date")

              fill_in :initiative_signature_start_date_date, with: nil, fill_options: { clear: :backspace }
              fill_in_datepicker :initiative_signature_start_date_date, with: 1.month.since(initiative.signature_end_date).strftime("%d/%m/%Y")
            end

            within "[data-content]" do
              find("*[type=submit]").click
            end

            expect(page).to have_admin_callout("There was a problem updating the initiative.")

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
        within("tr", text: translated(initiative.title)) do
          find("button[data-component='dropdown']").click
          click_on "Answer"
        end

        within ".edit_initiative_answer" do
          expect(page).to have_no_css("#initiative_signature_start_date_date")
          expect(page).to have_no_css("#initiative_signature_end_date_date")
        end
      end
    end
  end
end
