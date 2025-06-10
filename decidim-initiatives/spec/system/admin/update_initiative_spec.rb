# frozen_string_literal: true

require "spec_helper"

describe "User prints the initiative" do
  include_context "when admins initiative"

  context "when initiative update" do
    context "and user is admin" do
      let(:attributes) { attributes_for(:initiative, organization:) }

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_admin_initiatives.initiatives_path
      end

      it "Updates published initiative data" do
        page.find(".action-icon--edit").click

        within ".edit_initiative" do
          fill_in :initiative_title, with: "This is an updated title"
        end

        within("[data-content]") do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout "The initiative has been successfully updated."
      end

      it "updates the initiative" do
        page.find(".action-icon--edit").click

        fill_in_i18n(
          :initiative_title,
          "#initiative-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n_editor(
          :initiative_description,
          "#initiative-description-tabs",
          **attributes[:description].except("machine_translations")
        )

        within("[data-content]") do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout "The initiative has been successfully updated."
        visit decidim_admin.root_path
        expect(page).to have_content("updated the #{translated(attributes[:title])} initiative")
      end

      context "when initiative is in created state" do
        before do
          initiative.created!
        end

        it "updates type, scope and signature type" do
          page.find(".action-icon--edit").click
          within ".edit_initiative" do
            select translated(other_initiatives_type.title), from: "initiative_type_id"
            select translated(other_initiatives_type_scope.scope.name), from: "initiative_decidim_scope_id"
            select "In-person", from: "initiative_signature_type"
          end

          within("[data-content]") do
            find("*[type=submit]").click
          end

          expect(page).to have_admin_callout "The initiative has been successfully updated."
        end

        it "displays initiative attachments" do
          page.find(".action-icon--edit").click
          expect(page).to have_link("Edit")
          expect(page).to have_link("New")
        end
      end

      context "when initiative is in validating state" do
        before do
          initiative.validating!
        end

        it "updates type, scope and signature type" do
          page.find(".action-icon--edit").click
          within ".edit_initiative" do
            select translated(other_initiatives_type.title), from: "initiative_type_id"
            select translated(other_initiatives_type_scope.scope.name), from: "initiative_decidim_scope_id"
            select "In-person", from: "initiative_signature_type"
          end

          within("[data-content]") do
            find("*[type=submit]").click
          end

          expect(page).to have_admin_callout "The initiative has been successfully updated."
        end

        it "displays initiative attachments" do
          page.find(".action-icon--edit").click
          expect(page).to have_link("Edit")
          expect(page).to have_link("New")
        end
      end

      context "when initiative is in accepted state" do
        before do
          initiative.accepted!
        end

        it "update of type, scope and signature type are disabled" do
          page.find(".action-icon--edit").click

          within ".edit_initiative" do
            expect(page).to have_css("#initiative_type_id[disabled]")
            expect(page).to have_css("#initiative_decidim_scope_id[disabled]")
            expect(page).to have_css("#initiative_signature_type[disabled]")
          end
        end

        it "displays initiative attachments" do
          page.find(".action-icon--edit").click
          expect(page).to have_link("Edit")
          expect(page).to have_link("New")
        end
      end

      context "when there is a single initiative type" do
        let!(:other_initiatives_type) { nil }
        let!(:other_initiatives_type_scope) { nil }

        before do
          initiative.created!
        end

        it "update of type, scope and signature type are disabled" do
          page.find(".action-icon--edit").click

          within ".edit_initiative" do
            expect(page).to have_no_css("label[for='initiative_type_id']")
            expect(page).to have_no_css("#initiative_type_id")
          end
        end
      end
    end
  end
end
