# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage process attachments examples" do
  let!(:attachment) do
    Decidim::AttachmentUploader.enable_processing = true
    create(:participatory_process_attachment, participatory_process: participatory_process)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.participatory_process_path(participatory_process)
    click_link "Attachments"
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

    expect(page).to have_content(stripped(translated(attachment.title, locale: :en)))
    expect(page).to have_content(stripped(translated(attachment.description, locale: :en)))
    expect(page).to have_content(attachment.file_type)
    expect(page).to have_css("img[src~='#{attachment.thumbnail_url}']")
  end

  it "can add attachments to a process" do
    find("#attachments .actions .new").click

    within ".new_participatory_process_attachment" do
      fill_in_i18n(
        :participatory_process_attachment_title,
        "#title-tabs",
        en: "Very Important Document",
        es: "Documento Muy Importante",
        ca: "Document Molt Important"
      )

      fill_in_i18n(
        :participatory_process_attachment_description,
        "#description-tabs",
        en: "This document contains important information",
        es: "Este documento contiene información importante",
        ca: "Aquest document conté informació important"
      )

      attach_file :participatory_process_attachment_file, File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", "Exampledocument.pdf")
      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "#attachments table" do
      expect(page).to have_link("Very Important Document")
    end
  end

  it "can delete an attachment from a process" do
    within find("tr", text: stripped(translated(attachment.title))) do
      click_link "Destroy"
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    expect(page).to_not have_content(translated(attachment.title, locale: :en))
  end

  it "can update an attachment" do
    within "#attachments" do
      within find("tr", text: stripped(translated(attachment.title))) do
        click_link "Edit"
      end
    end

    within ".edit_participatory_process_attachment" do
      fill_in_i18n(
        :participatory_process_attachment_title,
        "#title-tabs",
        en: "This is a nice photo",
        es: "Una foto muy guay",
        ca: "Aquesta foto és ben xula"
      )

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "#attachments table" do
      expect(page).to have_link("This is a nice photo")
    end
  end
end
