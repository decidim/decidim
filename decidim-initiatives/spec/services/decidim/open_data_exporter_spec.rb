# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:resource_file_name) { "initiatives" }
  let!(:resource) { create(:initiative, :open, organization:) }
  let(:resource_title) { "## initiatives" }
  let(:help_lines) do
    [
      "reference: The reference of the initiative. An unique identifier for this platform."
    ]
  end
  let(:unpublished_resource) { create(:initiative, :created, organization:) }

  it_behaves_like "open data exporter"
end
