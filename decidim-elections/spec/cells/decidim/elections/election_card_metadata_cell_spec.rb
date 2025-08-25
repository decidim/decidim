# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe ElectionCardMetadataCell, type: :cell do
    controller Decidim::Elections::ElectionsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/elections/election_card_metadata", election) }
    let(:cell_html) { my_cell.call }
    let(:election) { create(:election) }
    let(:component) { election.component }
    let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

    it "renders as unpublished" do
      expect(subject.to_s).to include('<span class="unpublished label">Unpublished</span>')
    end

    context "when the election is scheduled" do
      let(:election) { create(:election, :published, :scheduled) }

      it "renders as scheduled" do
        expect(subject.to_s).to include('<span class="scheduled label">Scheduled</span>')
        expect(subject.to_s).to include("Not started yet")
      end
    end

    context "when the election is ongoing" do
      let(:election) { create(:election, :published, :ongoing, end_at: 1.9.days.from_now) }

      it "renders as ongoing" do
        expect(subject.to_s).to include('<span class="ongoing label">Ongoing</span>')
        expect(subject.to_s).to include("2 days remaining")
      end
    end

    context "when the election is finished" do
      let(:election) { create(:election, :published, :finished) }

      it "renders as finished" do
        expect(subject.to_s).to include('<span class="finished label">Finished</span>')
        expect(subject.to_s).to include("Finished: #{election.end_at.strftime("%d/%m/%Y")}")
      end
    end

    context "when the election has results published" do
      let(:election) { create(:election, :published, :finished, :published_results) }

      it "renders as results published" do
        expect(subject.to_s).to include('<span class="finished label">Finished</span>')
        expect(subject.to_s).to include("Results published: #{election.published_results_at.strftime("%d/%m/%Y")}")
      end
    end
  end
end
