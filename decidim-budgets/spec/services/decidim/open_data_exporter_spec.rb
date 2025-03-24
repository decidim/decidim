# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:resource_file_name) { "projects" }
  let(:component) do
    create(:budgets_component, organization:, published_at: Time.current)
  end
  let!(:resource) { create(:project, component:) }
  let(:resource_title) { "## projects (1 resource)" }
  let(:help_lines) do
    [
      "* id: The unique identifier of the project"
    ]
  end
  let(:unpublished_component) do
    create(:budgets_component, organization:, published_at: nil)
  end
  let(:unpublished_resource) { create(:project, component: unpublished_component) }

  before do
    I18n.backend.reload!
    I18n.backend.store_translations(
      :en,
      decidim: {
        open_data: {
          help: {
            projects: {
              test_field: "Test field for projects serializer subscription"
            }
          }
        }
      }
    )
  end

  it_behaves_like "open data exporter"
end
