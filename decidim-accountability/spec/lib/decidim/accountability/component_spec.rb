# frozen_string_literal: true

require "spec_helper"

describe "Accountability component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:accountability_component) }
  let!(:organization) { component.organization }
  let!(:current_user) { create(:user, :confirmed, :admin, organization:) }

  describe "stats" do
    subject { current_stat[1][:data] }

    let(:raw_stats) do
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.filter(name: stats_name).with_context(component).flat_map { |name, data| [component_manifest.name, name, data] }
      end
    end

    let(:stats) { raw_stats.select { |stat| stat[0] == :accountability } }
    let!(:result) { create(:result, component:) }
    let(:current_stat) { stats.find { |stat| stat[1][:name] == stats_name } }

    describe "comments_count" do
      let(:stats_name) { :comments_count }

      before do
        create_list(:comment, 3, commentable: result)
      end

      it "counts the comments" do
        expect(Decidim::Comments::Comment.count).to eq 3
        expect(subject).to eq 3
      end
    end
  end

  describe "on edit", type: :system do
    let(:edit_component_path) do
      Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
    end

    before do
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    context "when comments_max_length is empty" do
      it_behaves_like "has mandatory config setting", :comments_max_length
    end
  end

  describe "hooks" do
    let!(:results) { create_list(:result, 5, component:) }

    before do
      perform_enqueued_jobs(only: [Decidim::FindAndUpdateDescendantsJob, Decidim::UpdateSearchIndexesJob])
    end

    describe "publish" do
      let(:component) { create(:accountability_component, published_at: nil) }

      it "adds the results to search index" do
        expect(Decidim::SearchableResource.where(resource: results)).to be_empty
        component.publish!

        perform_enqueued_jobs(only: [Decidim::FindAndUpdateDescendantsJob, Decidim::UpdateSearchIndexesJob]) do
          component.manifest.run_hooks(:publish, component)
        end

        expect(Decidim::SearchableResource.where(resource: results)).to be_present
        # 3 languages multiplied by 5 results
        expect(Decidim::SearchableResource.where(resource: results).count).to eq(15)
      end
    end

    describe "unpublish" do
      it "removes the results from search index" do
        # 3 languages multiplied by 5 results
        expect(Decidim::SearchableResource.where(resource: results).count).to eq(15)
        expect(Decidim::SearchableResource.where(resource: results)).to be_present
        component.unpublish!

        perform_enqueued_jobs(only: Decidim::UpdateSearchIndexesJob) do
          component.manifest.run_hooks(:publish, component)
        end

        expect(Decidim::SearchableResource.where(resource: results)).to be_empty
      end
    end
  end
end
