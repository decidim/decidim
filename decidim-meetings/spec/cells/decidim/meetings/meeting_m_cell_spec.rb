# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingMCell, type: :cell do
    controller Decidim::Meetings::MeetingsController

    let!(:meeting) { create(:meeting, :published, created_at: "2001-01-01") }
    let(:model) { meeting }
    let(:the_cell) { cell("decidim/meetings/meeting_m", meeting, context: { show_space: }) }
    let(:cell_html) { the_cell.call }

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(cell_html).to have_css(".card--meeting")
      end

      it "doesn't show creation date" do
        expect(cell_html).to have_no_content("Created at")
        expect(cell_html).to have_no_content(I18n.l(meeting.created_at.to_date, format: :decidim_short))
      end

      context "when there are long descriptions" do
        before do
          meeting.update!(description: { en: "A really long text" * 800 })
        end

        it "truncates the description" do
          truncated_description_length = cell_html.find(".card__text--paragraph").text.strip.length
          expect(truncated_description_length).to be < 130
        end
      end

      context "with attached image" do
        let!(:attachment) { create(:attachment, attached_to: meeting) }

        it "renders the image" do
          expect(cell_html).to have_css(".card__image")
        end
      end
    end

    context "when title contains special html entities" do
      let(:show_space) { true }

      before do
        @original_title = meeting.title["en"]
        meeting.update!(title: { en: "#{meeting.title["en"]} &'<" })
        meeting.reload
      end

      it "escapes them correctly" do
        expect(the_cell.title).not_to eq("#{@original_title} &amp;&#39;&lt;")
        # as the `cell` test helper wraps content in a Capybara artifact that already converts html entities
        # we should compare with the expected visual result, as we were checking the DOM instead of the html
        expect(cell_html).to have_content("#{@original_title} &'<")
      end
    end
  end
end
