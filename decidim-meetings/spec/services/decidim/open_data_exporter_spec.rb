# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:resource_file_name) { "meetings" }
  let(:component) do
    create(:meeting_component, organization:, published_at: Time.current)
  end
  let!(:resource) { create(:meeting, component:) }
  let(:resource_title) { "## meetings" }
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
