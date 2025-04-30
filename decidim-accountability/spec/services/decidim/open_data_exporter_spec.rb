# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  describe "results" do
    let(:resource_file_name) { "results" }
    let(:component) do
      create(:accountability_component, organization:, published_at: Time.current)
    end
    let!(:resource) { create(:result, component:) }
    let(:resource_title) { "## results (1 resource)" }
    let(:help_lines) do
      [
        "* id: The unique identifier of the result"
      ]
    end
    let(:unpublished_component) do
      create(:accountability_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:result, component: unpublished_component) }

    it_behaves_like "open data exporter"
  end

  describe "result_comments" do
    let(:resource_file_name) { "result_comments" }
    let(:component) do
      create(:accountability_component, organization:, published_at: Time.current)
    end
    let(:result) { create(:result, component:) }
    let!(:resource) { create(:comment, commentable: result) }
    let(:resource_title) { "## result_comments (1 resource)" }
    let(:help_lines) do
      [
        "* id: The id for this comment"
      ]
    end
    let(:unpublished_component) do
      create(:accountability_component, organization:, published_at: nil)
    end
    let(:unpublished_result) { create(:result, component: unpublished_component) }
    let(:unpublished_resource) { create(:comment, commentable: unpublished_result) }

    it_behaves_like "open data exporter"
  end
end
