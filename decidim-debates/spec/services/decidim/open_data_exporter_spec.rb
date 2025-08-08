# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  describe "debates" do
    let(:resource_file_name) { "debates" }
    let(:component) do
      create(:debates_component, organization:, published_at: Time.current)
    end
    let!(:resource) { create(:debate, component:) }

    let(:second_component) do
      create(:debates_component, organization:, published_at: Time.current)
    end
    let!(:second_resource) { create(:debate, :closed, component: second_component) }

    let(:resource_title) { "## debates (2 resources)" }
    let(:help_lines) do
      [
        "* id: The unique identifier of the debate",
        "* conclusions: The conclusions of the debate if it was closed"
      ]
    end
    let(:unpublished_component) do
      create(:debates_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:debate, component: unpublished_component) }

    it_behaves_like "open data exporter"
  end

  describe "debates by deleted user" do
    let(:resource_file_name) { "debates" }
    let(:component) do
      create(:debates_component, organization:, published_at: Time.current)
    end

    let!(:deleted_user) { create(:user, :confirmed, :deleted, organization:) }
    let!(:resource) { create(:debate, component:, author: deleted_user) }

    let(:second_component) do
      create(:debates_component, organization:, published_at: Time.current)
    end
    let!(:second_resource) { create(:debate, :closed, component: second_component, author: deleted_user) }

    let(:resource_title) { "## debates (2 resources)" }
    let(:help_lines) do
      [
        "* id: The unique identifier of the debate",
        "* conclusions: The conclusions of the debate if it was closed"
      ]
    end
    let(:unpublished_component) do
      create(:debates_component, organization:, published_at: nil)
    end
    let(:unpublished_resource) { create(:debate, component: unpublished_component) }

    it_behaves_like "open data exporter"
  end

  describe "debate_comments" do
    let(:resource_file_name) { "debate_comments" }
    let(:component) do
      create(:debates_component, organization:, published_at: Time.current)
    end
    let(:debate) { create(:debate, component:) }
    let!(:resource) { create(:comment, commentable: debate) }
    let(:resource_title) { "## debate_comments (1 resource)" }
    let(:help_lines) do
      [
        "* id: The id for this comment"
      ]
    end
    let(:unpublished_component) do
      create(:debates_component, organization:, published_at: nil)
    end
    let(:unpublished_debate) { create(:debate, component: unpublished_component) }
    let(:unpublished_resource) { create(:comment, commentable: unpublished_debate) }

    it_behaves_like "open data exporter"
  end
end
