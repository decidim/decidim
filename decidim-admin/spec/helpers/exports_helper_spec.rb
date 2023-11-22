# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ExportsHelper do
      subject do
        Nokogiri::HTML(helper.export_dropdown(component))
      end

      let!(:component) { create(:component, manifest_name: "dummy") }

      it "creates a dropdown an export for each format and artifact" do
        expect(subject.css("li.exports--dummies").length).to eq(3)
        expect(subject.css("li.exports--format--csv").length).to eq(1)
        expect(subject.css("li.exports--format--excel").length).to eq(1)
      end

      it "creates links for each format" do
        link = subject.css("li.exports--format--csv.exports--dummies a")[0]
        expect(link["href"]).to eq("/admin/participatory_processes/#{component.participatory_space.slug}/components/#{component.id}/exports.CSV?id=dummies")
        expect(link["data-method"]).to eq("post")
      end

      describe "export_dropdowns" do
        subject do
          Nokogiri::HTML(helper.export_dropdowns(query, component))
        end

        let(:conditions) { "" }
        let(:query) do
          double(
            result: [double(id: 1)],
            conditions:
          )
        end

        before do
          allow(helper).to receive(:query).and_return(query)
          allow(helper).to receive(:render_dropdown).and_call_original
        end

        context "with no query" do
          it "does not create link for selection" do
            expect(subject).to have_selector("#export-dropdown")
            expect(subject).not_to have_selector("#export-selection-dropdown")
            expect(subject).to have_content("Export all")
            expect(subject).not_to have_content("Export selectioin")
            expect(helper).to have_received(:render_dropdown).with(component:, resource_id: nil, filters: {}).once
            expect(helper).not_to have_received(:render_dropdown).with(component:, resource_id: nil, filters: { id_in: [1] })
          end
        end

        context "with query" do
          let(:conditions) { "dummt condition" }

          it "creates link for selection and all" do
            expect(subject).to have_selector("#export-dropdown")
            expect(subject).to have_selector("#export-selection-dropdown")
            expect(subject).to have_content("Export all")
            expect(subject).to have_content("Export selection")
            expect(helper).to have_received(:render_dropdown).with(component:, resource_id: nil, filters: { id_in: [1] }).once
            expect(helper).to have_received(:render_dropdown).with(component:, resource_id: nil, filters: {}).once
          end
        end
      end
    end
  end
end
