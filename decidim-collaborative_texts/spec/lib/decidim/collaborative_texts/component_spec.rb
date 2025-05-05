# frozen_string_literal: true

require "spec_helper"

describe "CollaborativeTexts component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:collaborative_text_component) }
  let(:organization) { component.organization }
  let!(:current_user) { create(:user, :confirmed, :admin, organization:) }

  describe "stats" do
    subject { current_stat[1][:data] }

    let(:raw_stats) do
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.filter(name: stats_name).with_context(component).flat_map { |name, data| [component_manifest.name, name, data] }
      end
    end

    let(:stats) do
      raw_stats.select { |stat| stat[0] == :collaborative_texts }
    end

    let!(:document) { create(:collaborative_text_document) }
    let(:component) { document.component }
    let!(:another_document) { create(:collaborative_text_document, component:) }
    let!(:published_document) { create(:collaborative_text_document, :published, component:) }

    let(:current_stat) { stats.find { |stat| stat[1][:name] == stats_name } }

    describe "all_collaborative_texts_count" do
      let(:stats_name) { :all_collaborative_texts_count }

      it "counts all documents" do
        expect(Decidim::CollaborativeTexts::Document.where(component:).count).to eq 3
        expect(subject).to eq 3
      end
    end

    describe "published_collaborative_texts_count" do
      let(:stats_name) { :collaborative_texts_count }

      it "only counts published documents" do
        expect(Decidim::CollaborativeTexts::Document.where(component:).published.count).to eq 1
        expect(subject).to eq 1
      end
    end
  end
end
