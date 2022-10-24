# frozen_string_literal: true

shared_examples "manage attachments examples" do
  context "when processing attachments" do
    let!(:attachment) { create(:attachment, attached_to:, attachment_collection:) }

    before do
      visit current_path
    end

    it "lists all the attachments for the process" do
      within "#attachments table" do
        expect(page).to have_content(translated(attachment.title, locale: :en))
        expect(page).to have_content(translated(attachment_collection.name, locale: :en))
        expect(page).to have_content(attachment.file_type)
        expect(page).to have_content(attachment_file_size(attachment))
      end
    end

    it "can view an attachment details" do
      within "#attachments table" do
        click_link "Edit"
      end

      expect(page).to have_selector("input#attachment_title_en[value='#{translated(attachment.title, locale: :en)}']")
      expect(page).to have_selector("input#attachment_description_en[value='#{translated(attachment.description, locale: :en)}']")
      expect(page).to have_selector("input#attachment_weight[value='#{attachment.weight}']")
      expect(page).to have_select("attachment_attachment_collection_id", selected: translated(attachment_collection.name, locale: :en))
      expect(page).to have_css("img[src~='#{attachment.url}']")
    end

    it "can add attachments without a collection to a process" do
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
      end

      dynamically_attach_file(:attachment_file, Decidim::Dev.asset("Exampledocument.pdf"))

      within ".new_attachment" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#attachments table" do
        expect(page).to have_text("Very Important Document")
      end
    end

    it "can add attachments within a collection to a process" do
      find(".card-title a.new").click

      within ".new_attachment" do
        fill_in_i18n(
          :attachment_title,
          "#attachment-title-tabs",
          en: "Document inside a collection",
          es: "Documento Muy Importante",
          ca: "Document Molt Important"
        )

        fill_in_i18n(
          :attachment_description,
          "#attachment-description-tabs",
          en: "This document belongs to a collection",
          es: "Este documento pertenece a una colección",
          ca: "Aquest document pertany a una col·lecció"
        )

        select translated(attachment_collection.name, locale: :en), from: "attachment_attachment_collection_id"
      end

      dynamically_attach_file(:attachment_file, Decidim::Dev.asset("Exampledocument.pdf"))

      within ".new_attachment" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#attachments table" do
        expect(page).to have_text("Document inside a collection")
        expect(page).to have_text(translated(attachment_collection.name, locale: :en))
      end
    end

    it "can remove an attachment from a collection" do
      within "#attachments" do
        within find("tr", text: translated(attachment.title)) do
          expect(page).to have_text(translated(attachment_collection.name, locale: :en))
          click_link "Edit"
        end
      end

      within ".edit_attachment" do
        select "", from: "attachment_attachment_collection_id"

        find("*[type=submit]").click
      end

      within "#attachments" do
        within find("tr", text: translated(attachment.title)) do
          expect(page).to have_no_text(translated(attachment_collection.name, locale: :en))
        end
      end
    end

    it "can delete an attachment from a process" do
      within find("tr", text: translated(attachment.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      expect(page).to have_no_content(translated(attachment.title, locale: :en))
    end

    it "can update an attachment" do
      within "#attachments" do
        within find("tr", text: translated(attachment.title)) do
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
        expect(page).to have_text("This is a nice photo")
      end
    end
  end
end
