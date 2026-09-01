# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  describe "proposals" do
    let(:resource_file_name) { "proposals" }
    let(:component) do
      create(:proposal_component, organization:, published_at: Time.current)
    end
    let!(:resource) { create(:proposal, component:) }
    let(:resource_title) { "## proposals (1 resource)" }
    let(:help_lines) do
      [
        "* id: The unique identifier for the proposal"
      ]
    end
    let(:unpublished_component) do
      create(:proposal_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:proposal, component: unpublished_component) }

    it_behaves_like "open data exporter"
  end

  describe "proposals by deleted user" do
    let(:resource_file_name) { "proposals" }
    let(:component) do
      create(:proposal_component, organization:, published_at: Time.current)
    end
    let!(:deleted_user) { create(:user, :confirmed, :deleted, organization:) }
    let!(:resource) { create(:proposal, component:, users: [deleted_user]) }
    let(:resource_title) { "## proposals (1 resource)" }
    let(:help_lines) do
      [
        "* id: The unique identifier for the proposal"
      ]
    end
    let(:unpublished_component) do
      create(:proposal_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:proposal, component: unpublished_component, users: [deleted_user]) }

    it_behaves_like "open data exporter"
  end

  describe "proposal_comments" do
    let(:resource_file_name) { "proposal_comments" }
    let(:component) do
      create(:proposal_component, organization:, published_at: Time.current)
    end
    let!(:commentable) { create(:proposal, component:) }
    let!(:resource) { create(:comment, commentable:) }
    let(:resource_title) { "## proposals (1 resource)" }
    let(:help_lines) do
      [
        "* id: The unique identifier for the proposal"
      ]
    end
    let(:unpublished_component) do
      create(:proposal_component, organization:, published_at: nil)
    end
    let(:unpublished_commentable) { create(:proposal, component: unpublished_component) }
    let!(:unpublished_resource) { create(:comment, commentable: unpublished_commentable) }

    it_behaves_like "open data exporter"
  end

  describe "proposals with multi-paragraph bodies" do
    let(:organization) { create(:organization) }
    let(:path) { "/tmp/test-open-data-multiline-proposals.zip" }
    let(:component) do
      create(:proposal_component, organization:, published_at: Time.current)
    end
    # Bodies are exported through `convert_to_plain_text`, which wraps the text and
    # keeps the paragraph breaks, so a single proposal spans several physical lines
    # of the generated CSV.
    let(:body) do
      { "en" => "<p>#{"lorem ipsum " * 12}</p><p>#{"dolor sit amet " * 12}</p>" }
    end
    let!(:proposals) { create_list(:proposal, 2, component:, body:) }
    let(:readme) do
      subject.export
      Zip::File.open(path).glob("README.md").first.get_input_stream.read
    end

    it "counts resources, not lines of the generated CSV" do
      expect(readme[/^### proposals \(.*\)$/]).to eq("### proposals (2 resources)")
    end
  end
end
