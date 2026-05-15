# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcesses::ParticipatoryProcessGroupStatsPresenter do
    subject { described_class.new(participatory_process_group:) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let(:participatory_process_group) { create(:participatory_process_group, organization:) }

    describe "#collection" do
      let(:manifest) do
        Decidim::ComponentManifest.new.tap do |manifest|
          manifest.name = "Test"
        end
      end

      before do
        manifest.stats.register :foo, priority: StatsRegistry::MEDIUM_PRIORITY, &proc { 10 }
        manifest.stats.register :bar, priority: StatsRegistry::MEDIUM_PRIORITY, &proc { 0 }

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
        expect(data).to have_key(:name)
        expect(data).to have_key(:data)
        expect(data[:name]).to eq :foo
        expect(data[:data][0]).to eq 10
      end

      it "does not return 0 values" do
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
        manifest_meetings.stats.register :comments_count, tag: :comments, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY, &proc { 10 }
        manifest_meetings.stats.register :followers_count, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY, &proc { 5 }
        manifest_proposals.stats.register :comments_count, tag: :comments, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY, &proc { 5 }
        manifest_proposals.stats.register :followers_count, tag: :followers, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY, &proc { 3 }

        I18n.backend.store_translations(
          :en,
          decidim: {
            participatory_processes: {
              statistics: {
                comments_count: "Comments",
                followers_count: "Followers"
              }
            }
          }
        )

        allow(Decidim).to receive(:component_manifests).and_return([manifest_meetings, manifest_proposals])
      end

      it "returns the sum of all the comments from proposals and meetings" do
        data = subject.collection.find { |stat| stat[:name] == :comments_count }
        expect(data).not_to be_nil
        expect(data[:data][0]).to eq 15
      end

      it "returns the sum of all the followers from proposals and meetings" do
        data = subject.collection.find { |stat| stat[:name] == :followers_count }
        expect(data).not_to be_nil
        expect(data[:data][0]).to eq 8 if data
      end

      it "contains only two stats" do
        expect(subject.collection.count).to be(2)
      end
    end
  end
end
