# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/space_cell_changes_button_text_cta"

module Decidim::Votings
  describe VotingMCell, type: :cell do
    controller Decidim::Votings::VotingsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/votings/voting_m", voting, context: { show_space: show_space }) }
    let(:cell_html) { my_cell.call }
    let(:start_time) { 2.days.ago }
    let(:end_time) { 1.day.from_now }
    let!(:voting) { create(:voting, :published, start_time: start_time, end_time: end_time) }
    let(:model) { voting }
    let(:user) { create :user, organization: voting.organization }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--voting")
      end

      it "renders the start and end time " do
        voting_start = I18n.l(start_time.to_date, format: :decidim_short)
        voting_end = I18n.l(end_time.to_date, format: :decidim_short)

        expect(subject).to have_css(".card-data__item--centerblock", text: voting_start)
        expect(subject).to have_css(".card-data__item--centerblock", text: voting_end)
      end

      it "renders the title and description" do
        description = strip_tags(translated(voting.description, locale: :en))
        expect(subject).to have_css(".card__title", text: translated(voting.title))
        expect(subject).to have_css(".card__text", text: description)
      end

      it "renders the badge name" do
        expect(subject).to have_css(".card__text--status", text: "Ongoing")
      end

      it "renders the banner image" do
        expect(subject).to have_css(".card__image")
      end
    end
  end
end
