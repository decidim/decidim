# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:resource_file_name) { "results" }
  let(:component) do
    create(:accountability_component, organization:, published_at: Time.current)
  end
  let!(:resource) { create(:result, component:) }
  let(:resource_title) { "## accountability" }
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
