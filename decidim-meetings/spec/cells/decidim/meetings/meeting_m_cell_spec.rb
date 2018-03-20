# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingCell, type: :cell do
    let!(:meeting) { create(:meeting) }

    context "when rendering" do
      it do
        html = cell("decidim/meetings/meeting_m", meeting).call
        expect(html).to have_css(".card--meeting")
      end
    end
  end
end
