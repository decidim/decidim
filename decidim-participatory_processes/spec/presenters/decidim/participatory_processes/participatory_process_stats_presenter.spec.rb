# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcessStatsPresenter do
    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:process) { create(:participatory_process, organization: organization) }
    let!(:feature) { create(:feature, participatory_space: process) }
    let!(:feature2) { create(:feature, participatory_space: process) }
    let!(:feature3) { create(:feature, participatory_space: process) }

    subject { described_class.new(participatory_process: process) }

    before do
      feature.manifest.stats.register :foo, priority: StatsRegistry::HIGH_PRIORITY, &proc { 10 }
      feature2.manifest.stats.register :bar, priority: StatsRegistry::MEDIUM_PRIORITY, &proc { 20 }
      feature3.manifest.stats.register :baz, priority: StatsRegistry::LOW_PRIORITY, &proc { 30 }
      I18n.backend.store_translations(
        :en,
        decidim: {
          participatory_processes: {
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
