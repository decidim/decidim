# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImportsHelper do
      describe "#import_dropdown" do
        subject do
          Nokogiri::HTML(helper.import_dropdown(component))
        end

        let!(:component) { create(:component, manifest_name: "dummy") }

        it "creates an import dropdown" do
          expect(subject.css("li").length).to eq(1)
        end

        it "creates a link" do
          import_path = "/admin/participatory_processes/#{component.participatory_space.slug}/components/#{component.id}/imports/new?name=dummies"
          link = subject.at_css("a[href='#{import_path}']")

          expect(link["href"]).to eq(import_path)
        end
      end

      describe "#mime_types" do
        it "returns the expected mime types" do
          expect(helper.mime_types).to eq(
            csv: "CSV",
            json: "JSON",
            xlsx: "Excel (.xlsx)"
          )
        end
      end

      describe "#admin_imports_path" do
        let(:component) { create(:dummy_component) }

        it "returns the correct link" do
          expect(helper.admin_imports_path(component, name: "dummies")).to eq("/admin/participatory_processes/#{component.participatory_space.slug}/components/#{component.id}/imports/new?name=dummies")
        end
      end

      describe "#admin_imports_example_path" do
        let(:component) { create(:dummy_component) }

        it "returns the correct link" do
          expect(helper.admin_imports_example_path(component, name: "dummies", format: "json")).to eq("/admin/participatory_processes/#{component.participatory_space.slug}/components/#{component.id}/imports/example.json?name=dummies")
        end
      end
    end
  end
end
