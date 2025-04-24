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
    let!(:process_component) { create(:component, participatory_space: process) }
    let!(:assembly_component) { create(:component, participatory_space: assembly) }

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

    describe "#collection" do
      it "renders a collection of high priority stats including users and processes" do
        stats = [
          { admin: true, data: [1], name: :users_count, icon_name: "user-line", tooltip_key: "users_count_tooltip", sub_title: nil },
          { admin: true, data: [1], name: :processes_count, icon_name: "treasure-map-line", tooltip_key: "processes_count_tooltip", sub_title: nil },
          { admin: true, data: [1], name: :assemblies_count, icon_name: "government-line", tooltip_key: "assemblies_count_tooltip", sub_title: nil },
          { admin: true, data: [10], name: :foo, icon_name: nil, tooltip_key: nil, sub_title: nil },
          { admin: true, data: [20], name: :dummies_count_high, icon_name: nil, tooltip_key: nil, sub_title: nil }
        ]

        expect(subject.collection).to eq(stats)
      end
    end
  end
end
