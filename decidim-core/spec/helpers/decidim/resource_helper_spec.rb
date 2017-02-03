# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ResourceHelper do
    let(:feature) { create(:feature) }
    let(:resource) { create(:dummy_resource, feature: feature) }

    describe "decidim_resource_path" do
      subject { helper.decidim_resource_path(resource) }

      it { is_expected.to eq("/participatory_processes/#{feature.participatory_process.id}/features/#{feature.id}/dummy_resources/#{resource.id}") }
    end

    describe "decidim_resource_path" do
      subject { helper.decidim_resource_url(resource) }

      it { is_expected.to eq("http://#{feature.organization.host}/participatory_processes/#{feature.participatory_process.id}/features/#{feature.id}/dummy_resources/#{resource.id}") }
    end

    describe "linked_resources_for" do
      let(:linked_resource) { create(:dummy_resource, feature: feature, title: "Dummy title") }

      before do
        resource.link_resources(linked_resource, "test_link")
      end

      it "renders the linked resources using the template" do
        content = helper.linked_resources_for(resource, :dummy, "test_link")

        expect(content).to include("Dummy title")
        expect(content).to include("section-heading")
        expect(content).to include("Related dummy")
      end
    end
  end
end
