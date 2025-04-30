# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:resource_file_name) { "participatory_processes" }
  let!(:resource) { create(:participatory_process, organization:) }
  let(:resource_title) { "## participatory_processes (1 resource)" }
  let(:help_lines) do
    [
      "id: The unique identifier of this process"
    ]
  end
  let(:unpublished_resource) { create(:participatory_process, :unpublished, organization:) }

  it_behaves_like "open data exporter"
end
