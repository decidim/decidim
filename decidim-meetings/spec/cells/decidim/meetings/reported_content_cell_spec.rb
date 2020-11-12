# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe ReportedContentCell, type: :cell do
    controller Decidim::Meetings::MeetingsController

    let!(:meeting) { create(:meeting, description: { "en" => "the meeting's description" }) }

    context "when rendering" do
      it "renders the meeting's description" do
        html = cell("decidim/reported_content", meeting).call
        expect(html).to have_content("the meeting's description")
      end
    end
  end
end
