# frozen_string_literal: true

require "spec_helper"

describe "Conferences", type: :system do
  let(:organization) { create(:organization) }
  let!(:conference) { create(:conference, organization:) }

  def visit_conference
    visit decidim_conferences.conference_path(conference)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are no attachments and media links" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conference_media_path(conference) }
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
      visit decidim_conferences.conference_media_path(conference)
    end

    it "the menu link is shown" do
      visit decidim_conferences.conference_path(conference)

      within ".process-nav" do
        expect(page).to have_content("MEDIA")
      end
    end

    it "shows them" do
      within "div.wrapper .conference-media" do
        expect(page).to have_content("MEDIA AND LINKS")
        expect(page).to have_content(/#{translated(media_link.title, locale: :en)}/i)
        expect(page).to have_css(".media-links a")
      end
    end
  end

  context "when it has attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to: conference) }

    let!(:image) { create(:attachment, attached_to: conference) }

    before do
      visit decidim_conferences.conference_media_path(conference)
    end

    it "shows them" do
      within "div.wrapper .documents" do
        expect(page).to have_content(/#{translated(document.title, locale: :en)}/i)
      end

      within "div.wrapper .images" do
        expect(page).to have_css(".picture__content img")
      end
    end
  end

  context "when are ordered by weight" do
    let!(:last_document) { create(:attachment, :with_pdf, attached_to: conference, weight: 2) }
    let!(:first_document) { create(:attachment, :with_pdf, attached_to: conference, weight: 1) }
    let!(:last_image) { create(:attachment, attached_to: conference, weight: 2) }
    let!(:fist_image) { create(:attachment, attached_to: conference, weight: 1) }

    before do
      visit decidim_conferences.conference_media_path(conference)
    end

    it "shows them ordered" do
      within "div.wrapper .documents" do
        expect(translated(first_document.title, locale: :en)).to appear_before(translated(last_document.title, locale: :en))
      end

      within "div.wrapper .images" do
        expect(strip_tags(translated(fist_image.description, locale: :en))).to appear_before(strip_tags(translated(last_image.description, locale: :en)))
      end
    end
  end
end
