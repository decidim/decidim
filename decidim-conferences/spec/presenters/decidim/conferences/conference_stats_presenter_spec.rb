# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Conferences::ConferenceStatsPresenter do
    subject { described_class.new(conference: conference) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:conference) { create(:conference, organization: organization) }
    let!(:component) { create(:component, participatory_space: conference) }

    let(:manifest) do
      Decidim::ComponentManifest.new.tap do |manifest|
        manifest.name = "Test"
      end
    end

    before do
      manifest.stats.register :foo, priority: StatsRegistry::HIGH_PRIORITY, &proc { 10 }

      I18n.backend.store_translations(
        :en,
        decidim: {
          conferences: {
            statistics: {
              foo: "Foo"
            }
          }
        }
      )

      allow(Decidim).to receive(:component_manifests).and_return([manifest])
    end

    describe "#highlighted" do
      it "renders a collection of stats including users and proceses" do
        expect(subject.highlighted).to include("10 Foo")
      end
    end
  end
end
