# frozen_string_literal: true

require "spec_helper"

describe "Conference speakers" do
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

      expect(page).to have_no_content("Speakers")
    end
  end

  context "when the conference does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_conferences.conference_conference_speakers_path(conference_slug: 999_999_999) }
    end
  end

  context "when there are some published conference speakers" do
    let!(:conference_speakers) { create_list(:conference_speaker, 2, :published, conference:) }

    before do
      visit decidim_conferences.conference_conference_speakers_path(conference)
    end

    context "and accessing from the conference homepage" do
      it "the menu link is shown" do
        visit decidim_conferences.conference_path(conference)

        within ".conference__nav-container" do
          expect(page).to have_content("Speakers")
          click_on "Speakers"
        end

        expect(page).to have_current_path decidim_conferences.conference_conference_speakers_path(conference)
      end
    end

    it "lists all conference speakers" do
      within "#conference_speakers-grid" do
        expect(page).to have_css("[data-conference-speaker]", count: 2)

        conference_speakers.each do |conference_speaker|
          expect(page).to have_content(Decidim::ConferenceSpeakerPresenter.new(conference_speaker).name)
        end
      end
    end
  end

  describe "publication of conference speakers" do
    let!(:speaker1) { create(:conference_speaker, :published, conference:) }
    let!(:speaker2) { create(:conference_speaker, conference:) }
    let!(:speaker3) { create(:conference_speaker, conference:) }
    let!(:user) { create(:user, :admin, :confirmed, organization:) }

    before do
      login_as user, scope: :user
      visit decidim_conferences.conference_conference_speakers_path(conference)
    end

    context "when there are some unpublished speakers" do
      it "is not shown in the public list" do
        within "#conference_speakers-grid" do
          expect(page).to have_css("[data-conference-speaker]", count: 1)
        end
      end

      it "publishes the speaker" do
        visit decidim_admin.root_path
        click_on "Conferences"
        click_on "conference_title"
        click_on "Speakers"

        within "tr", text: speaker2.full_name do
          find("button[data-component='dropdown']").click
          expect(page).to have_link("Publish")
          click_link_or_button "Publish"
        end

        visit decidim_conferences.conference_conference_speakers_path(conference)

        within "#conference_speakers-grid" do
          expect(page).to have_css("[data-conference-speaker]", count: 2)
        end
      end
    end

    context "when there are some published speakers" do
      before do
        speaker2.update!(published_at: Time.current)
        speaker3.update!(published_at: Time.current)
        visit decidim_conferences.conference_conference_speakers_path(conference)
      end

      it "is shown in the public list" do
        within "#conference_speakers-grid" do
          expect(page).to have_css("[data-conference-speaker]", count: 3)
        end
      end

      it "unpublishes the speaker" do
        visit decidim_admin.root_path
        click_on "Conferences"
        click_on "conference_title"
        click_on "Speakers"

        within "tr", text: speaker1.full_name do
          find("button[data-component='dropdown']").click
          expect(page).to have_link("Unpublish")
          click_link_or_button "Unpublish"
        end

        visit decidim_conferences.conference_conference_speakers_path(conference)

        within "#conference_speakers-grid" do
          expect(page).to have_css("[data-conference-speaker]", count: 2)
        end
      end
    end
  end
end
