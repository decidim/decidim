# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcesses::ParticipatoryProcessStatsPresenter do
    subject { described_class.new(participatory_process: process) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let!(:process) { create(:participatory_process, organization:) }

    describe "#collection" do
      let(:manifest) do
        Decidim::ComponentManifest.new.tap do |manifest|
          manifest.name = "Test"
        end
      end

      before do
        manifest.stats.register :foo, priority: StatsRegistry::HIGH_PRIORITY, &proc { 10 }
        manifest.stats.register :bar, priority: StatsRegistry::HIGH_PRIORITY, &proc { 0 }

        I18n.backend.store_translations(
          :en,
          decidim: {
            participatory_processes: {
              statistics: {
                foo: "Foo",
                bar: "Bar"
              }
            }
          }
        )

        allow(Decidim).to receive(:component_manifests).and_return([manifest])
      end

      it "return a collection of stats including stats title and value" do
        data = subject.collection.first
        expect(data).not_to be_nil
        expect(data).to have_key(:stat_title)
        expect(data).to have_key(:stat_number)
        expect(data[:stat_title]).to eq :foo
        expect(data[:stat_number]).to eq 10
      end

      it "doesn't return 0 values" do
        data = subject.collection.second
        expect(data).to be_nil
      end
    end

    describe "count stats from multiple components" do
      let(:manifest_proposals) do
        Decidim::ComponentManifest.new.tap do |manifest|
          manifest.name = "proposals"
        end
      end

      let(:manifest_meetings) do
        Decidim::ComponentManifest.new.tap do |manifest|
          manifest.name = "meetings"
        end
      end

      before do
        manifest_meetings.stats.register :comments_count, tag: :comments, &proc { 10 }
        manifest_meetings.stats.register :endorsements_count, tag: :endorsements, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY, &proc { 5 }
        manifest_proposals.stats.register :comments_count, tag: :comments, &proc { 5 }
        manifest_proposals.stats.register :endorsements_count, tag: :endorsements, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY, &proc { 3 }

        I18n.backend.store_translations(
          :en,
          decidim: {
            participatory_processes: {
              statistics: {
                comments_count: "Comments",
                endorsements_count: "Endorsements"
              }
            }
          }
        )

        allow(Decidim).to receive(:component_manifests).and_return([manifest_meetings, manifest_proposals])
      end

      it "returns the sum of all the comments from proposals and meetings" do
        data = subject.collection.find { |stat| stat[:stat_title] == :comments_count }
        expect(data).not_to be_nil
        expect(data[:stat_number]).to eq 15
      end

      it "returns the sum of all the endorsements from proposals and meetings" do
        data = subject.collection.find { |stat| stat[:stat_title] == :endorsements_count }
        expect(data).not_to be_nil
        expect(data[:stat_number]).to eq 8
      end

      it "contains only two stats" do
        expect(subject.collection.count).to be(2)
      end
    end
  end
end
