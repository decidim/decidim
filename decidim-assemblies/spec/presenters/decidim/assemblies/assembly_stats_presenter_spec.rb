# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AssemblyStatsPresenter do
    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:assembly) { create(:assembly, organization: organization) }
    let!(:feature) { create(:feature, participatory_space: assembly) }
    let!(:feature2) { create(:feature, participatory_space: assembly) }
    let!(:feature3) { create(:feature, participatory_space: assembly) }

    subject { described_class.new(assembly: assembly) }

    before do
      feature.manifest.stats.register :foo, priority: StatsRegistry::HIGH_PRIORITY, &proc { 10 }
      feature2.manifest.stats.register :bar, priority: StatsRegistry::MEDIUM_PRIORITY, &proc { 20 }
      feature3.manifest.stats.register :baz, priority: StatsRegistry::LOW_PRIORITY, &proc { 30 }
      I18n.backend.store_translations(
        :en,
        decidim: {
          assemblies: {
            statistics: {
              foo: "Foo",
              bar: "Bar",
              baz: "Baz"
            }
          }
        }
      )

      allow(Decidim).to receive(:feature_manifests).and_return([feature.manifest, feature2.manifest, feature3.manifest])
    end

    describe "#highlighted" do
      it "renders a collection of stats including users and proceses" do
        expect(subject.highlighted).to include("10 Foo")
        expect(subject.highlighted).to include("20 Bar")
        expect(subject.highlighted).to_not include("30 Baz")
      end
    end
  end
end
