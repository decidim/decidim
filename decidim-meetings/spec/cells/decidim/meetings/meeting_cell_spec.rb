# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingCell, type: :cell do
    controller Decidim::Meetings::MeetingsController

    let!(:meeting) { create(:meeting) }

    context "when rendering" do
      it "renders the card" do
        html = cell("decidim/meetings/meeting", meeting).call
        expect(html).to have_css(".card--meeting")
      end
    end
  end
end
