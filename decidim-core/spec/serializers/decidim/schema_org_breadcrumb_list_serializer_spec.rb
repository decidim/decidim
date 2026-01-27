# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SchemaOrgBreadcrumbListSerializer do
    subject do
      described_class.new({ breadcrumb_items:, base_url:, organization_name: })
    end

    let(:breadcrumb_items) do
      [
        {
          label: "Processes",
          url: "/processes",
          active: true
        }
      ]
    end

    let(:base_url) { "https://example.org" }
    let(:participatory_process) { create(:participatory_process) }
    let(:organization_name) { "ACME Corp" }

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the @context" do
        expect(serialized[:@context]).to eq("https://schema.org")
      end

      it "serializes the @type" do
        expect(serialized[:@type]).to eq("BreadcrumbList")
      end

      it "serializes the name" do
        expect(serialized[:name]).to eq("ACME Corp breadcrumb")
      end

      it "serializes the breadcrumb items" do
        expected_items_elements = [
          { "@type": "ListItem", position: 1, name: "Processes", item: "https://example.org/processes" }
        ]
        expect(serialized[:itemListElement]).to eq(expected_items_elements)
      end

      context "when there are empty items" do
        let(:breadcrumb_items) do
          [
            {
              label: "Processes",
              url: "/processes",
              active: true
            },
            {}
          ]
        end

        it "ignores them" do
          expected_items_elements = [
            { "@type": "ListItem", position: 1, name: "Processes", item: "https://example.org/processes" }
          ]
          expect(serialized[:itemListElement]).to eq(expected_items_elements)
        end
      end

      context "when there are only items without URLs" do
        let(:breadcrumb_items) do
          [
            {
              label: "Profile",
              active: true
            }
          ]
        end

        it "returns an empty JSON" do
          expect(serialized).to eq({})
        end
      end
    end
  end
end
