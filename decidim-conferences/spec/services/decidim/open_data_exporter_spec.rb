# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:resource_file_name) { "conferences" }
  let!(:resource) { create(:conference, organization:) }
  let(:resource_title) { "## conferences" }
  let(:help_lines) do
    [
      "* id: The unique identifier of this conference"
    ]
  end
  let(:unpublished_resource) { create(:conference, :unpublished, organization:) }

  it_behaves_like "open data exporter"
end
