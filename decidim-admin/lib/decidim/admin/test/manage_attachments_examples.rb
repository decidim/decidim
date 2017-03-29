# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage attachments examples" do
  let!(:attachment) do
    Decidim::AttachmentUploader.enable_processing = true
    create(:attachment, attached_to: attached_to)
  end

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
    expect(page).to have_content(attachment.file.url)
    expect(page).to have_css("img[src~='#{attachment.thumbnail_url}']")
  end

  it "can add attachments to a process" do
    find(".card-title a.new").click

    within ".new_participatory_process_attachment" do
      fill_in_i18n(
        :attachment_title,
        "#title-tabs",
        en: "Very Important Document",
        es: "Documento Muy Importante",
        ca: "Document Molt Important"
      )

      fill_in_i18n(
        :attachment_description,
        "#description-tabs",
        en: "This document contains important information",
        es: "Este documento contiene información importante",
        ca: "Aquest document conté informació important"
      )

      attach_file :attachment_file, Decidim::Dev.asset("Exampledocument.pdf")
      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "#attachments table" do
      expect(page).to have_link("Very Important Document")
    end
  end

  it "can delete an attachment from a process" do
    within find("tr", text: stripped(translated(attachment.title))) do
      page.find('a.action-icon--remove').click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    expect(page).not_to have_content(translated(attachment.title, locale: :en))
  end

  it "can update an attachment" do
    within "#attachments" do
      within find("tr", text: stripped(translated(attachment.title))) do
        page.find('a.action-icon--edit').click
      end
    end

    within ".edit_participatory_process_attachment" do
      fill_in_i18n(
        :attachment_title,
        "#title-tabs",
        en: "This is a nice photo",
        es: "Una foto muy guay",
        ca: "Aquesta foto és ben xula"
      )

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "#attachments table" do
      expect(page).to have_link("This is a nice photo")
    end
  end
end
