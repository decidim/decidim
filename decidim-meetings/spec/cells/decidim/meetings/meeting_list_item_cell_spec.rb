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
      let!(:original_title) { meeting.title["en"] }

      before do
        meeting.update!(title: { en: "<strong>#{original_title}</strong> &'<" })
        meeting.reload
      end

      it "escapes them correctly" do
        expect(subject.to_s).to include("&lt;strong&gt;#{original_title}&lt;/strong&gt; &amp;'&lt;")
      end
    end
  end
end
