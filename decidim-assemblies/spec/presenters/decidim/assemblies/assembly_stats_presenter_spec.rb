# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Assemblies::AssemblyStatsPresenter do
    subject { described_class.new(assembly:) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let!(:assembly) { create(:assembly, organization:) }
    let!(:component) { create(:component, participatory_space: assembly) }

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
            assemblies: {
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

    describe "comments count stat" do
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

      let(:manifest_budgets) do
        Decidim::ComponentManifest.new.tap do |manifest|
          manifest.name = "budgets"
        end
      end

      before do
        manifest_meetings.stats.register :comments_count, tag: :comments, &proc { 10 }
        manifest_proposals.stats.register :comments_count, tag: :comments, &proc { 5 }
        manifest_budgets.stats.register :comments_count, tag: :comments, &proc { 3 }

        I18n.backend.store_translations(
          :en,
          decidim: {
            participatory_processes: {
              statistics: {
                comments_count: "Comments"
              }
            }
          }
        )

        allow(Decidim).to receive(:component_manifests).and_return([manifest_meetings, manifest_proposals, manifest_budgets])
      end

      it "return the sum of all the comments from proposals, meetings and budgets" do
        data = subject.collection.first
        expect(data).not_to be_nil
        expect(data[:stat_title]).to eq :comments_count
        expect(data[:stat_number]).to eq 18
      end

      it "contains only one stat" do
        data = subject.collection.second
        expect(data).to be_nil
      end
    end
  end
end
