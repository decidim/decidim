# frozen_string_literal: true

require "spec_helper"
require "decidim/assemblies/test/factories"

module Decidim
  describe HomeStatsPresenter do
    subject { described_class.new(organization: organization) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:process) { create(:participatory_process, :published, organization: organization) }
    let!(:assembly) { create(:assembly, :published, organization: organization) }
    let!(:process_component) { create :component, participatory_space: process }
    let!(:assembly_component) { create :component, participatory_space: assembly }

    around do |example|
      Decidim.stats.register :foo, priority: StatsRegistry::HIGH_PRIORITY, &proc { 10 }
      Decidim.stats.register :bar, priority: StatsRegistry::MEDIUM_PRIORITY, &proc { 20 }
      Decidim.stats.register :baz, priority: StatsRegistry::LOW_PRIORITY, &proc { 30 }

      example.run

      Decidim.stats.stats.reject! { |s| s[:name] == :baz }
      Decidim.stats.stats.reject! { |s| s[:name] == :bar }
      Decidim.stats.stats.reject! { |s| s[:name] == :foo }
    end

    before do
      manifests = Decidim.component_manifests.select { |manifest| manifest.name == :dummy }
      allow(Decidim).to receive(:component_manifests).and_return(manifests)
    end

    describe "#highlighted" do
      it "renders a collection of high priority stats including users and proceses" do
        stats =
          [{ stat_number: 1, stat_title: :users_count },
           { stat_number: 1, stat_title: :processes_count },
           { stat_number: 1, stat_title: :assemblies_count },
           { stat_number: 10, stat_title: :foo },
           { stat_number: 20, stat_title: :dummies_count_high }]

        expect(subject.highlighted).to eq(stats)
      end
    end

    describe "#not_highlighted" do
      it "renders a collection of medium priority stats" do
        stats =
          [{ stat_number: 20, stat_title: :bar },
           { stat_number: 200, stat_title: :dummies_count_medium }]

        expect(subject.not_highlighted).to eq(stats)
      end
    end
  end
end
