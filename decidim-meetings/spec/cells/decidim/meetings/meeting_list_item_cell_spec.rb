# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingListItemCell, type: :cell do
    subject { my_cell.call }

    let!(:meeting) { create(:meeting, :published) }
    let(:my_cell) { cell("decidim/meetings/meeting_list_item", meeting) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_css(".card--list__item")
      end
    end

    context "when title contains special html entities" do
      it "escapes them correctly" do
        expect(subject.to_s).to include(decidim_escape_translated(meeting.title).gsub("&#39;", "\'"))
      end
    end
  end
end
