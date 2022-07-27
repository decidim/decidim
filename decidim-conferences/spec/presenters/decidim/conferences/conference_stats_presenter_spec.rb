# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Conferences::ConferenceStatsPresenter do
    subject { described_class.new(conference:) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let!(:conference) { create(:conference, organization:) }
    let!(:component) { create(:component, participatory_space: conference) }

    describe "#highlighted" do
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

      it "renders a collection of stats including users and proceses" do
        expect(subject.highlighted).to include({ stat_number: 10, stat_title: :foo })
      end
    end

    describe "comments count stat" do
      let(:manifest_debates) do
        Decidim::ComponentManifest.new.tap do |manifest|
          manifest.name = "debates"
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
        manifest_debates.stats.register :comments_count, tag: :comments, &proc { 5 }
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

        allow(Decidim).to receive(:component_manifests).and_return([manifest_meetings, manifest_debates, manifest_budgets])
      end

      it "return the sum of all the comments from debates, meetings and budgets" do
        data = subject.highlighted.first
        expect(data).not_to be_nil
        expect(data[:stat_title]).to eq :comments_count
        expect(data[:stat_number]).to eq 18
      end

      it "contains only one stat" do
        data = subject.highlighted.second
        expect(data).to be_nil
      end
    end
  end
end
