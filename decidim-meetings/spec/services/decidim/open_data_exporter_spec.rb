# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  describe "meetings" do
    let(:resource_file_name) { "meetings" }
    let(:component) do
      create(:meeting_component, organization:, published_at: Time.current)
    end
    let!(:resource) { create(:meeting, component:) }
    let(:resource_title) { "## meetings (1 resource)" }
    let(:help_lines) do
      [
        "* id: The unique identifier of the meeting"
      ]
    end
    let(:unpublished_component) do
      create(:meeting_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:meeting, component: unpublished_component) }

    it_behaves_like "open data exporter"
  end

  describe "meeting created by deleted user" do
    let!(:deleted_user) { create(:user, :confirmed, :deleted, organization:) }
    let(:resource_file_name) { "meetings" }
    let(:component) do
      create(:meeting_component, organization:, published_at: Time.current)
    end
    let!(:resource) { create(:meeting, component:, author: deleted_user) }
    let(:resource_title) { "## meetings (1 resource)" }
    let(:help_lines) do
      [
        "* id: The unique identifier of the meeting"
      ]
    end
    let(:unpublished_component) do
      create(:meeting_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:meeting, component: unpublished_component, author: deleted_user) }

    it_behaves_like "open data exporter"
  end

  describe "meeting_comments" do
    let(:resource_file_name) { "meeting_comments" }
    let(:component) do
      create(:meeting_component, organization:, published_at: Time.current)
    end
    let!(:commentable) { create(:meeting, component:) }
    let!(:resource) { create(:comment, commentable:) }
    let(:resource_title) { "## meeting_comments (1 resource)" }
    let(:help_lines) do
      [
        "* id: The id for this comment"
      ]
    end
    let(:unpublished_component) do
      create(:meeting_component, organization:, published_at: nil)
    end
    let(:unpublished_commentable) { create(:meeting, component: unpublished_component) }
    let(:unpublished_resource) { create(:comment, commentable: unpublished_commentable) }

    it_behaves_like "open data exporter"
  end
end
