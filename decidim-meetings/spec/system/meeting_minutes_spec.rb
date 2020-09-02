# frozen_string_literal: true

require "spec_helper"

describe "Meeting minutes", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meeting) { create(:meeting, component: component) }

  let(:visible) { true }

  def visit_meeting
    visit resource_locator(meeting).path
  end

  context "when meeting minutes is not visible" do
    before do
      create(:minutes, meeting: meeting, visible: false)
    end

    it "the section minutes is not visible" do
      visit_meeting

      expect(page).to have_no_content("MEETING MINUTES")
      expect(page).not_to have_css(".minutes-section")
    end
  end

  context "when meeting minutes is visible" do
    let!(:minutes) { create(:minutes, meeting: meeting, visible: :visible) }

    it "shows the minutes section" do
      visit_meeting
      expect(page).to have_content("MEETING MINUTES")
      expect(page).to have_css(".minutes-section")

      within ".minutes-section" do
        expect(page).to have_i18n_content(minutes.description)
      end
    end

    context "when video url is present" do
      it "shows the video url" do
        visit_meeting
        within ".minutes-section" do
          expect(page).to have_content(minutes.video_url)
        end
      end
    end

    context "when audio url is present" do
      it "shows the audio url" do
        visit_meeting
        within ".minutes-section" do
          expect(page).to have_content(minutes.audio_url)
        end
      end
    end

    context "when video url is NOT present" do
      it "does not show the video url" do
        meeting.minutes.update(video_url: nil)
        visit_meeting
        within ".minutes-section" do
          expect(page).not_to have_content(minutes.video_url)
        end
      end
    end

    context "when audio url is NOT present" do
      it "does not show the audio url" do
        meeting.minutes.update(audio_url: nil)
        visit_meeting
        within ".minutes-section" do
          expect(page).not_to have_content(minutes.audio_url)
        end
      end
    end
  end
end
