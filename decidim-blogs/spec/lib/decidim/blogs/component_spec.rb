# frozen_string_literal: true

require "spec_helper"

describe "Blogs component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:post_component) }
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
      raw_stats.select { |stat| stat[0] == :blogs }
    end

    let!(:post) { create(:post, component:) }
    let!(:another_post) { create(:post, component:) }

    let(:current_stat) { stats.find { |stat| stat[1][:name] == stats_name } }

    describe "posts_count" do
      let(:stats_name) { :posts_count }

      it "counts posts in the component" do
        expect(Decidim::Blogs::Post.where(component:).count).to eq 2
        expect(subject).to eq 2
      end
    end

    describe "comments_count" do
      let(:stats_name) { :comments_count }

      before do
        create_list(:comment, 3, commentable: post)
        create_list(:comment, 5, commentable: another_post)
      end

      it "counts the comments across all posts in the component" do
        expect(Decidim::Comments::Comment.count).to eq 8
        expect(subject).to eq 8
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
end
