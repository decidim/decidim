# frozen_string_literal: true

require "spec_helper"

describe "Conference speakers", type: :system do
  let(:organization) { create(:organization) }
  let(:conference) { create(:conference, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no conference speakers and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conference_conference_speakers_path(conference) }
    end
  end

  context "when there are no conference speakers and accessing from the conference homepage" do
    it "the menu link is not shown" do
      visit decidim_conferences.conference_path(conference)

      expect(page).to have_no_content("SPEAKERS")
    end
  end

  context "when the conference does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conference_conference_speakers_path(conference_slug: 999_999_999) }
    end
  end

  context "when there are some published conference speakers" do
    let!(:conference_speakers) { create_list(:conference_speaker, 2, conference:) }

    before do
      visit decidim_conferences.conference_conference_speakers_path(conference)
    end

    context "and accessing from the conference homepage" do
      it "the menu link is shown" do
        visit decidim_conferences.conference_path(conference)

        within ".process-nav__content" do
          expect(page).to have_content("SPEAKERS")
          click_link "Speakers"
        end

        expect(page).to have_current_path decidim_conferences.conference_conference_speakers_path(conference)
      end
    end

    it "lists all conference speakers" do
      within "#conference_speakers-grid" do
        expect(page).to have_selector(".column.conference-speaker", count: 2)

        conference_speakers.each do |conference_speaker|
          expect(page).to have_content(Decidim::ConferenceSpeakerPresenter.new(conference_speaker).name)
        end
      end
    end
  end
end
