# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingCell, type: :cell do
    controller Decidim::Meetings::MeetingsController

    let!(:meeting) { create(:meeting) }

    let(:the_cell) { cell("decidim/meetings/meeting", meeting) }
    let(:cell_html) { the_cell.call }

    context "when rendering" do
      it "renders the card" do
        expect(cell_html).to have_css(".card--meeting")
      end
    end

    context "when title contains special html entities" do
      let(:show_space) { true }

      before do
        @original_title = meeting.title["en"]
        meeting.update!(title: { en: "#{meeting.title["en"]} &'<" })
        meeting.reload
      end

      it "escapes them correclty" do
        # as the `cell` test helper wraps conent in a Capybara artifact that already converts html entities
        # we should compare with the expected visual result, as we were checking the DOM instead of the html
        expect(cell_html).to have_content("#{@original_title} &'<")
      end
    end
  end
end
