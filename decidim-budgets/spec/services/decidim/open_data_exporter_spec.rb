# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:organization) { create(:organization) }
  let(:path) { "/tmp/test-open-data.zip" }
  let(:zip_contents) { Zip::File.open(path) }
  let(:csv_file) { zip_contents.glob(csv_file_name).first }
  let(:csv_data) { csv_file.get_input_stream.read }

  describe "budgets" do
    let(:csv_file_name) { "*open-data-projects.csv" }
    let(:component) do
      create(:budgets_component, organization:, published_at: Time.current)
    end
    let!(:project) { create(:project, component:) }

    before do
      subject.export
    end

    it "includes a CSV with projects" do
      expect(csv_file).not_to be_nil
    end

    it "includes the projects data" do
      expect(csv_data).to include(translated(project.title).gsub("\"", "\"\""))
    end

    describe "README content" do
      let(:csv_file_name) { "README.md" }

      it "includes the projects help description" do
        expect(csv_data).to include("## budgets")
        expect(csv_data).to include("* id: The unique identifier of the project")
      end

      it "does not have any missing translation" do
        expect(csv_data).not_to include("Translation missing")
      end
    end

    context "with unpublished components" do
      let(:component) do
        create(:budgets_component, organization:, published_at: nil)
      end

      it "does not include the projects data" do
        expect(csv_data).not_to include(translated(project.title).gsub("\"", "\"\""))
      end
    end
  end
end
