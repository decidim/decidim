# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process attachments" do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage process attachments examples" do
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

        expect(page).to have_admin_callout("successfully")

        wait_enqueued_jobs do
          visit decidim.notifications_path
          expect(page).to have_content("A new document has been added to")
        end
      end
    end
  end
end
