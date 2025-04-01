# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:resource_file_name) { "assemblies" }
  let!(:resource) { create(:assembly, organization:) }
  let(:resource_title) { "## assemblies (1 resource)" }
  let(:help_lines) do
    [
      "* id: The unique identifier of this assembly"
    ]
  end
  let(:unpublished_resource) { create(:assembly, :unpublished, organization:) }

  before do
    Bullet.add_safelist type: :unused_eager_loading, class_name: "Decidim::Assembly", association: :attachment_collections
    Bullet.add_safelist type: :unused_eager_loading, class_name: "Decidim::Assembly", association: :categories
  end

  it_behaves_like "open data exporter"
end
