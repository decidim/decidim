# frozen_string_literal: true

shared_examples "manage attachments examples" do
  context "processing attachments", processing_uploads_for: Decidim::AttachmentUploader do
    let!(:attachment) { create(:attachment, attached_to: attached_to) }

    before do
      visit current_path
    end

    it "lists all the attachments for the process" do
      within "#attachments table" do
        expect(page).to have_content(translated(attachment.title, locale: :en))
        expect(page).to have_content(attachment.file_type)
      end
    end

    it "can view an attachment details" do
      within "#attachments table" do
        click_link translated(attachment.title, locale: :en)
      end

      expect(page).to have_selector("input#attachment_title_en[value='#{translated(attachment.title, locale: :en)}']")
      expect(page).to have_selector("input#attachment_description_en[value='#{translated(attachment.description, locale: :en)}']")
      expect(page).to have_css("img[src~='#{attachment.url}']")
    end

    it "can add attachments to a process" do
      find(".card-title a.new").click

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

        attach_file :attachment_file, Decidim::Dev.asset("Exampledocument.pdf")
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#attachments table" do
        expect(page).to have_link("Very Important Document")
      end
    end

    it "can delete an attachment from a process" do
      within find("tr", text: stripped(translated(attachment.title))) do
        accept_confirm { click_link "Destroy" }
      end

      expect(page).to have_admin_callout("successfully")

      expect(page).to have_no_content(translated(attachment.title, locale: :en))
    end

    it "can update an attachment" do
      within "#attachments" do
        within find("tr", text: stripped(translated(attachment.title))) do
          click_link "Edit"
        end
      end

      within ".edit_attachment" do
        fill_in_i18n(
          :attachment_title,
          "#attachment-title-tabs",
          en: "This is a nice photo",
          es: "Una foto muy guay",
          ca: "Aquesta foto és ben xula"
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#attachments table" do
        expect(page).to have_link("This is a nice photo")
      end
    end
  end
end
