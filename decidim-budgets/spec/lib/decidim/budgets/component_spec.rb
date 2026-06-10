# frozen_string_literal: true

require "spec_helper"

describe "Budgets component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:budgets_component) }

  describe "stats" do
    subject { current_stat[1][:data] }

    let(:raw_stats) do
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.filter(name: stats_name).with_context(component).flat_map { |name, data| [component_manifest.name, name, data] }
      end
    end

    let(:stats) { raw_stats.select { |stat| stat[0] == :budgets } }
    let!(:budget) { create(:budget, component:) }
    let!(:project) { create(:project, budget:) }
    let(:current_stat) { stats.find { |stat| stat[1][:name] == stats_name } }

    describe "comments_count" do
      let(:stats_name) { :comments_count }

      before do
        create_list(:comment, 3, commentable: project)
      end

      it "counts the comments" do
        expect(Decidim::Comments::Comment.count).to eq 3
        expect(subject).to eq 3
      end
    end
  end
end
