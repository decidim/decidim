# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  describe "pages" do
    let(:resource_file_name) { "pages" }
    let(:component) do
      create(:page_component, name: "Published page title", organization:, published_at: Time.current)
    end
    let!(:resource) { create(:page, component:) }

    let(:second_component) do
      create(:page_component, name: "Second published page title", organization:, published_at: Time.current)
    end
    let!(:second_resource) { create(:page, component: second_component) }

    let(:resource_title) { "## pages" }
    let(:help_lines) do
      [
        "* id: The unique identifier of this page",
        "* title: The page title"
      ]
    end
    let(:unpublished_component) do
      create(:page_component, name: "Unpublished page title", organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:page, component: unpublished_component) }

    it_behaves_like "open data exporter"
  end
end
