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
        },
        {
          label: { ca: "Hola mon", es: "Hola mundo", en: "Hello world" },
          url: "/processes/hello-world",
          dropdown_cell: "decidim/participatory_processes/process_dropdown_metadata",
          resource: participatory_process
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
          { "@type": "ListItem", position: 1, name: "Processes", item: "https://example.org/processes" },
          { "@type": "ListItem", position: 2, name: "Hello world", item: "https://example.org/processes/hello-world" }
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
            {
              label: { ca: "Hola mon", es: "Hola mundo", en: "Hello world" },
              url: "/processes/hello-world",
              dropdown_cell: "decidim/participatory_processes/process_dropdown_metadata",
              resource: participatory_process
            },
            {}
          ]
        end

        it "ignores them" do
          expected_items_elements = [
            { "@type": "ListItem", position: 1, name: "Processes", item: "https://example.org/processes" },
            { "@type": "ListItem", position: 2, name: "Hello world", item: "https://example.org/processes/hello-world" }
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
