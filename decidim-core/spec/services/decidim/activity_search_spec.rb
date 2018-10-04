# frozen_string_literal: true

require "spec_helper"

module Decidim
  ActivitySearch.class_eval do
    def resource_types
      %w(
        Decidim::Comments::Comment
        Decidim::DummyResources::DummyResource
      )
    end
  end

  describe ActivitySearch do
    subject { search.results }

    let(:search) do
      described_class.new(organization: organization, resource_type: resource_type)
    end
    let(:organization) { create(:organization) }
    let(:resource_type) { "all" }

    context "with admin logs" do
      let!(:admin_log) { create(:action_log, visibility: "admin-only", organization: organization) }

      it { is_expected.not_to eq(admin_log) }
    end

    context "when a resource is not publicable" do
      let(:comment) { create(:comment) }
      let!(:action_log) do
        create(:action_log, action: "create", visibility: "public-only", resource: comment, organization: organization)
      end

      it { is_expected.to include(action_log) }
    end

    context "with update actions" do
      let!(:action_log) do
        create(:action_log, action: "update", visibility: "public-only", organization: organization)
      end

      it { is_expected.not_to include(action_log) }
    end

    context "when a resource is publicable" do
      let!(:action_log) do
        create(:action_log, action: action, visibility: "all", resource: resource, organization: organization)
      end
      let(:component) do
        create(:component, :published, organization: organization)
      end

      context "and it is not published" do
        let(:action) { "create" }
        let(:resource) do
          create(:dummy_resource, component: component, published_at: nil)
        end

        it { is_expected.not_to include(action_log) }
      end

      context "and it is published" do
        let(:action) { "publish" }
        let(:resource) do
          create(:dummy_resource, component: component, published_at: Time.current)
        end

        it { is_expected.to include(action_log) }
      end
    end
  end
end
