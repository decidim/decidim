# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingCell, type: :cell do
    controller Decidim::Meetings::MeetingsController

    let!(:meeting) { create(:meeting) }
    let(:model) { meeting }
    let(:cell_html) { cell("decidim/meetings/meeting_m", meeting, context: { show_space: show_space }).call }

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(cell_html).to have_css(".card--meeting")
      end
    end
  end
end
