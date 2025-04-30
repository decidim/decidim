# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:resource_file_name) { "initiatives" }
  let!(:resource) { create(:initiative, :open, organization:) }
  let(:resource_title) { "## initiatives (1 resource)" }
  let(:help_lines) do
    [
      "reference: The unique reference of the space"
    ]
  end
  let(:unpublished_resource) { create(:initiative, :created, organization:) }

  it_behaves_like "open data exporter"
end
