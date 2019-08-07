# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingListItemCell, type: :cell do
    let!(:meeting) { create(:meeting) }

    context "when rendering" do
      it "renders the card" do
        html = cell("decidim/meetings/meeting_list_item", meeting).call
        expect(html).to have_css(".card--list__item")
      end
    end
  end
end
