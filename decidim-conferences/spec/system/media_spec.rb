# frozen_string_literal: true

require "spec_helper"

describe "Conferences" do
  let(:organization) { create(:organization) }
  let!(:conference) { create(:conference, organization:) }

  def visit_conference
    visit decidim_conferences.conference_path(conference, locale: I18n.locale)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are no attachments and media links" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conference_media_path(conference, locale: I18n.locale) }
    end
  end

  context "when there are no attachments and accessing from the conference page" do
    before do
      visit_conference
    end

    it "the menu link is not shown" do
      expect(page).to have_no_content("MEDIA")
    end
  end

  context "when it has media links" do
    let!(:media_link) { create(:media_link, conference:) }

    before do
      visit decidim_conferences.conference_media_path(conference, locale: I18n.locale)
    end

    it "the menu link is shown" do
      visit decidim_conferences.conference_path(conference, locale: I18n.locale)

      within "aside .conference__nav-container" do
        expect(page).to have_content("Media")
      end
    end

    it "shows them" do
      within "#conference-media-links" do
        expect(page).to have_content("Media and Links")
        expect(page).to have_content(translated(media_link.title))
        expect(page).to have_css("[data-conference-media-links] a")
      end
    end
  end

  context "when it has attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to: conference) }

    let!(:image) { create(:attachment, attached_to: conference) }

    before do
      visit decidim_conferences.conference_media_path(conference, locale: I18n.locale)
    end

    it "shows them" do
      within "#conference-media-documents" do
        expect(page).to have_content(translated(document.title))
      end

      within "#conference-media-photos" do
        expect(page).to have_css("img")
      end
    end
  end

  context "when are ordered by weight" do
    let!(:last_document) { create(:attachment, :with_pdf, attached_to: conference, weight: 2) }
    let!(:first_document) { create(:attachment, :with_pdf, attached_to: conference, weight: 1) }
    let!(:last_image) { create(:attachment, attached_to: conference, weight: 2) }
    let!(:fist_image) { create(:attachment, attached_to: conference, weight: 1) }

    before do
      visit decidim_conferences.conference_media_path(conference, locale: I18n.locale)
    end

    it "shows them ordered" do
      within "#conference-media-documents" do
        expect(decidim_escape_translated(first_document.title).gsub("&quot;", "\"")).to appear_before(decidim_escape_translated(last_document.title).gsub("&quot;", "\""))
      end

      within "#conference-media-photos" do
        expect(decidim_escape_translated(fist_image.title).gsub("&quot;", "\"")).to appear_before(decidim_escape_translated(last_image.title).gsub("&quot;", "\""))
      end
    end
  end
end
