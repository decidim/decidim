# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ResourceHelper do
    let(:feature) { create(:feature) }
    let(:resource) { create(:dummy_resource, feature: feature) }

    describe "decidim_resource_path" do
      subject { helper.decidim_resource_path(resource) }

      it { is_expected.to eq("/participatory_processes/#{feature.participatory_process.id}/features/#{feature.id}/dummy_resource/#{resource.id}") }
    end

    describe "decidim_resource_path" do
      subject { helper.decidim_resource_url(resource) }

      it { is_expected.to eq("http://test.host/participatory_processes/#{feature.participatory_process.id}/features/#{feature.id}/dummy_resource/#{resource.id}") }
    end

    describe "linked_resources_for" do
      let(:linked_resource) { create(:dummy_resource, feature: feature) }

      before do
        resource.link_resources(linked_resource, "test_link")
      end

      it "renders the linked resources using the template" do
        content = helper.linked_resources_for(resource, :dummy, "test_link")
        expected = "<div class=\"section\"><h3 class=\"section-heading\">Related dummy</h3><ul>\n    <li>#{linked_resource.title}</li>\n</ul>\n</div>"

        expect(content).to eq(expected)
      end
    end
  end
end
