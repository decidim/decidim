# frozen_string_literal: true

require "spec_helper"

describe "Meeting minutes", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }
  let(:meeting) { create(:meeting, :published, :closed_with_minutes, closing_visible: visible, component: component) }

  let(:visible) { true }

  def visit_meeting
    visit resource_locator(meeting).path
  end

  context "when meeting minutes is not visible" do
    let(:visible) { false }

    it "the section minutes is not visible" do
      visit_meeting

      expect(page).to have_no_content("MEETING MINUTES")
      expect(page).not_to have_css(".minutes-section")
    end
  end

  context "when meeting minutes is visible" do
    it "shows the minutes section" do
      visit_meeting
      expect(page).to have_content("MEETING MINUTES")
      expect(page).to have_css(".minutes-section")

      within ".minutes-section" do
        expect(page).to have_content("RELATED INFORMATION")
        expect(page).to have_css("div.card--list__item", count: 2)
        expect(page).to have_content(meeting.audio_url)
        expect(page).to have_content(meeting.video_url)
      end
    end

    context "and minutes data is missing" do
      it "hides the section minutes" do
        meeting.update(
          video_url: nil,
          audio_url: nil
        )
        visit_meeting
        expect(page).to have_no_content("MEETING MINUTES")
        expect(page).not_to have_css(".minutes-section")
      end
    end

    context "when video url is present" do
      it "shows the video url" do
        visit_meeting
        within ".minutes-section" do
          expect(page).to have_content(meeting.video_url)
        end
      end
    end

    context "when audio url is present" do
      it "shows the audio url" do
        visit_meeting
        within ".minutes-section" do
          expect(page).to have_content(meeting.audio_url)
        end
      end
    end

    context "when video url is NOT present" do
      it "does not show the video url" do
        video_url = meeting.video_url
        meeting.update(video_url: nil)
        visit_meeting
        within ".minutes-section" do
          expect(page).to have_content("RELATED INFORMATION")
          expect(page).to have_css("div.card--list__item", count: 1)
          expect(page).to have_no_content(video_url)
        end
      end
    end

    context "when audio url is NOT present" do
      it "does not show the audio url" do
        audio_url = meeting.audio_url
        meeting.update(audio_url: nil)
        visit_meeting
        within ".minutes-section" do
          expect(page).to have_content("RELATED INFORMATION")
          expect(page).to have_css("div.card--list__item", count: 1)
          expect(page).to have_no_content(audio_url)
        end
      end
    end
  end
end
