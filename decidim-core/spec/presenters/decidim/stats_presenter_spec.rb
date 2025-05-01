# frozen_string_literal: true

require "spec_helper"

describe Decidim::StatsPresenter, type: :presenter do
  let(:scope_entity) { double("ScopeEntity") }
  let(:presenter) { described_class.new(scope_entity) }

  describe "#collection" do
    let(:priority) { Decidim::StatsRegistry::MEDIUM_PRIORITY }
    let(:conditions) { { priority: priority } }

    before do
      allow(presenter).to receive(:all_stats).with(priority: priority).and_return([
                                                                                    { name: "stat_1", data: [1, 23] },
                                                                                    { name: "stat_2", data: [0] },
                                                                                    { name: "stat_3", data: [45] }
                                                                                  ])
    end

    it "returns stats with non-empty data" do
      result = presenter.collection(priority:)

      expect(result).to contain_exactly({ name: "stat_1", data: [1, 23] }, { name: "stat_3", data: [45] })
    end

    it "rejects stats with blank or zero data" do
      result = presenter.collection(priority:)

      expect(result).not_to include({ name: "stat_2", data: [0] })
    end

    it "sums the data of stats with the same name" do
      allow(presenter).to receive(:all_stats).with(priority: priority).and_return([
                                                                                    { name: "stat_1", data: [12, 3] },
                                                                                    { name: "stat_1", data: [4] }
                                                                                  ])

      result = presenter.collection(priority:)

      expect(result).to contain_exactly({ name: "stat_1", data: [16, 3] })
    end
  end

  describe "#all_stats" do
    let(:conditions) { { priority: Decidim::StatsRegistry::MEDIUM_PRIORITY } }

    it "combines global stats and component stats" do
      allow(presenter).to receive(:global_stats).with(conditions).and_return([
                                                                               { name: "global_stat", data: [10, 20] }
                                                                             ])
      allow(presenter).to receive(:component_stats).with(conditions).and_return([
                                                                                  { name: "component_stat", data: [5, 15] }
                                                                                ])

      result = presenter.all_stats(conditions)

      expect(result).to include(
        { name: "global_stat", data: [10, 20] },
        { name: "component_stat", data: [5, 15] }
      )
    end
  end

  describe "#published_components" do
    context "when scope entity is a Decidim::Organization" do
      before do
        allow(scope_entity).to receive(:is_a?).with(Decidim::Organization).and_return(true)
        allow(scope_entity).to receive(:published_components).and_return(%w(component1 component2))
      end

      it "returns the published components of the organization" do
        expect(presenter.published_components).to eq(%w(component1 component2))
      end
    end
  end
end
