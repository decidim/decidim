# frozen_string_literal: true

require "spec_helper"
require "decidim/assemblies/test/factories"

module Decidim
  describe HomeStatsPresenter do
    subject { described_class.new(organization:) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let!(:process) { create(:participatory_process, :published, organization:) }
    let!(:assembly) { create(:assembly, :published, organization:) }
    let!(:process_component) { create :component, participatory_space: process }
    let!(:assembly_component) { create :component, participatory_space: assembly }
    let(:extra_manifest) do
      # The extra manifest registers the same stat as the actual component
      # manifest to test that there are no duplicate stats in the results.
      Decidim::ComponentManifest.new(name: :dummy_another).tap do |manifest|
        manifest.register_stat :dummies_count_medium, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
          components.count
        end
      end
    end

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
      manifests << extra_manifest
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
           { stat_number: 202, stat_title: :dummies_count_medium }]

        expect(subject.not_highlighted).to eq(stats)
      end
    end
  end
end
