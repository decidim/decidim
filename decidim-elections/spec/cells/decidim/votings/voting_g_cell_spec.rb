# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/space_cell_changes_button_text_cta"

module Decidim::Votings
  describe VotingGCell, type: :cell do
    controller Decidim::Votings::VotingsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/votings/voting_g", voting, context: { show_space: }) }
    let(:cell_html) { my_cell.call }
    let(:start_time) { 2.days.ago }
    let(:end_time) { 1.day.from_now }
    let(:voting) { create(:voting, :published, start_time:, end_time:) }
    let(:model) { voting }
    let(:user) { create(:user, organization: voting.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card__grid")
        expect(subject).to have_css("#votings__voting_#{voting.id}")
      end

      it "renders the start and end time" do
        voting_start = I18n.l(start_time.to_date, format: :decidim_short_with_month_name_short)
        voting_end = I18n.l(end_time.to_date, format: :decidim_short_with_month_name_short)

        expect(subject).to have_css(".card__grid-metadata span", text: voting_start)
        expect(subject).to have_css(".card__grid-metadata span", text: voting_end)
      end

      it "renders the title" do
        expect(subject).to have_css(".card__grid-text", text: translated(voting.title))
      end

      it "renders the banner image" do
        expect(subject).to have_css(".card__grid-img img")
      end

      describe "render different states" do
        context "when the voting is ongoing" do
          let!(:voting) { create(:voting, :ongoing) }

          it "renders the ongoing state" do
            expect(subject).to have_css("span.label.success", text: "Ongoing")
          end
        end

        context "when the voting is upcoming" do
          let!(:voting) { create(:voting, :upcoming) }

          it "renders the upcoming state" do
            expect(subject).to have_css("span.label.warning", text: "Upcoming")
          end
        end

        context "when the voting is finished" do
          let!(:voting) { create(:voting, :finished) }

          it "renders the finished state" do
            expect(subject).to have_css("span.label", text: "Finished")
          end
        end
      end

      describe "renders the different voting types" do
        context "when the voting is online" do
          let(:voting) { create(:voting, :online) }

          it "renders the online type" do
            within ".card-data__item" do
              expect(page).to have_content("Online")
            end
          end
        end

        context "when the voting is in person" do
          let(:voting) { create(:voting, :in_person) }

          it "renders the in person type" do
            within ".card-data__item" do
              expect(page).to have_content("In person")
            end
          end
        end

        context "when the voting is hybrid" do
          let(:voting) { create(:voting, :hybrid) }

          it "renders the hybrid type" do
            within ".card-data__item" do
              expect(page).to have_content("Hybrid")
            end
          end
        end
      end
    end
  end
end
