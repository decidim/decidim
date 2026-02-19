# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly attachments" do
  include_context "when admin administrating an assembly"

  let(:attached_to) { assembly }
  let(:attachment_collection) { create(:attachment_collection, collection_for: assembly) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    within_admin_sidebar_menu do
      click_on "Attachments"
    end
  end

  it_behaves_like "manage attachments examples" do
    context "when checking notifications" do
      it "successfully displays the notification" do
        create(:follow, user:, followable: attached_to)

        click_on "New attachment"

        within ".new_attachment" do
          fill_in_i18n(
            :attachment_title,
            "#attachment-title-tabs",
            en: "Very Important Document",
            es: "Documento Muy Importante",
            ca: "Document Molt Important"
          )

          fill_in_i18n(
            :attachment_description,
            "#attachment-description-tabs",
            en: "This document contains important information",
            es: "Este documento contiene información importante",
            ca: "Aquest document conté informació important"
          )
        end

        dynamically_attach_file(:attachment_file, Decidim::Dev.asset("Exampledocument.pdf"))

        within ".new_attachment" do
          find("*[type=submit]").click
        end

        expect(page).to have_callout("Attachment created successfully.")

        wait_enqueued_jobs do
          visit decidim.notifications_path
          expect(page).to have_content("A new document has been added to")
        end
      end
    end
  end
end
