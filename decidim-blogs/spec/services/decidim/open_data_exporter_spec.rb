# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  describe "posts" do
    let(:resource_file_name) { "posts" }
    let(:component) do
      create(:post_component, organization:, published_at: Time.current)
    end
    let!(:resource) { create(:post, component:) }

    let(:second_component) do
      create(:post_component, organization:, published_at: Time.current)
    end
    let!(:second_resource) { create(:post, component: second_component) }

    let(:resource_title) { "## posts (2 resources)" }
    let(:help_lines) do
      [
        "* id: The unique identifier of this post",
        "* title: The title of the post"
      ]
    end
    let(:unpublished_component) do
      create(:post_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:post, component: unpublished_component) }

    it_behaves_like "open data exporter"

    context "with unpublished posts" do
      let!(:unpublished_resource) { create(:post, published_at: 5.weeks.from_now, component:) }

      it_behaves_like "open data exporter"
    end
  end

  describe "posts by deleted user" do
    let(:resource_file_name) { "posts" }
    let(:component) do
      create(:post_component, organization:, published_at: Time.current)
    end

    let!(:deleted_user) { create(:user, :confirmed, :deleted, organization:) }
    let!(:resource) { create(:post, component:, author: deleted_user) }

    let(:second_component) do
      create(:post_component, organization:, published_at: Time.current)
    end
    let!(:second_resource) { create(:post, component: second_component, author: deleted_user) }

    let(:resource_title) { "## posts (2 resources)" }
    let(:help_lines) do
      [
        "* id: The unique identifier of this post",
        "* title: The title of the post"
      ]
    end
    let(:unpublished_component) do
      create(:post_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:post, component: unpublished_component) }

    it_behaves_like "open data exporter"
  end

  describe "post_comments" do
    let(:resource_file_name) { "post_comments" }
    let(:component) do
      create(:post_component, organization:, published_at: Time.current)
    end
    let(:post) { create(:post, component:) }
    let!(:resource) { create(:comment, commentable: post) }
    let(:resource_title) { "## post_comments (1 resource)" }
    let(:help_lines) do
      [
        "* id: The id for this comment"
      ]
    end
    let(:unpublished_component) do
      create(:post_component, organization:, published_at: nil)
    end
    let(:unpublished_post) { create(:post, component: unpublished_component) }
    let(:unpublished_resource) { create(:comment, commentable: unpublished_post) }

    it_behaves_like "open data exporter"
  end
end
