# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe DestroyPollingStationClosure do
    subject { described_class.new(closure, user) }

    let(:voting) { create(:voting) }
    let(:component) { create(:elections_component, participatory_space: voting) }
    let(:election) { create(:election, component:) }
    let(:polling_station) { create(:polling_station, voting:) }
    let(:polling_officer) { create(:polling_officer, voting:) }
    let(:user) { polling_officer }

    let!(:closure) { create :ps_closure, :with_results, election:, polling_station:, polling_officer: }

    it "broadcasts valid" do
      expect(subject.call).to broadcast(:ok)
    end

    it "removes the closure and existing results" do
      expect(Decidim::Votings::PollingStationClosure.count).to eq(1)
      expect(Decidim::Elections::Result.count).not_to be_zero
      subject.call
      expect(Decidim::Votings::PollingStationClosure.count).to be_zero
      expect(Decidim::Elections::Result.count).to be_zero
    end

    context "when closure is completed" do
      let(:closure) { create :ps_closure, :with_results, :completed, election:, polling_station:, polling_officer: }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end

      it "does not remove the closure and existing results" do
        subject.call
        expect(Decidim::Votings::PollingStationClosure.count).to eq(1)
        expect(Decidim::Elections::Result.count).not_to be_zero
      end
    end
  end
end
