# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe ElectionGCell, type: :cell do
    controller Decidim::Elections::ElectionsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/elections/election_g", election, context: { show_space: }) }
    let(:cell_html) { my_cell.call }
    let(:start_time) { 2.days.ago }
    let(:end_time) { 1.day.from_now }
    let!(:election) { create(:election, :complete, :published, start_time:, end_time:) }
    let(:model) { election }
    let(:user) { create(:user, organization: election.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card__grid")
        expect(subject).to have_css("#elections__election_#{election.id}")
      end

      it "renders the start and end time" do
        election_start = I18n.l(start_time.to_date, format: :decidim_short_with_month_name_short)
        election_end = I18n.l(end_time.to_date, format: :decidim_short_with_month_name_short)

        expect(subject).to have_css(".card__grid-metadata span", text: election_start)
        expect(subject).to have_css(".card__grid-metadata span", text: election_end)
      end

      it "renders the title" do
        expect(subject).to have_css(".card__grid-text", text: translated(election.title))
      end

      it "renders the badge name" do
        expect(subject).to have_css("span.label.success", text: "Active")
      end

      context "with attached image" do
        let(:image) { create(:attachment, :with_image, attached_to: election) }

        before do
          election.update!(attachments: [image])
        end

        it "shows the attached image" do
          expect(subject).to have_css(".card__grid-img img")
        end
      end
    end
  end
end
