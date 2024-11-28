# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"
require_relative "shared_examples"

module Decidim::Maintenance::ImportModels
  describe Area do
    subject { area }

    include_context "with taxonomy importer model context"
    # avoid using factories for this test in case old models are removed
    let!(:area) { described_class.create!(name: { "en" => "Area 1", "ca" => "Àrea 1" }, decidim_organization_id: organization.id, area_type_id: area_type.id) }
    let!(:another_area) { described_class.create!(name: { "en" => "Area 2", "ca" => "Àrea 2" }, decidim_organization_id: organization.id) }
    let(:area_type) { AreaType.create!(name: { "en" => "Area Type", "ca" => "Tipus Area" }, plural: { "en" => "Area Types" }, decidim_organization_id: organization.id) }

    let!(:external_area) { described_class.create!(name: { "en" => "External Area" }, decidim_organization_id: external_organization.id) }
    let(:root_taxonomy_name) { "~ Areas" }
    let(:resource) { participatory_process }

    before do
      participatory_process.update!(decidim_area_id: area.id)
      external_participatory_process.update!(decidim_area_id: external_area.id)
    end

    describe "#name" do
      it "returns the name" do
        expect(subject.name).to eq("en" => "Area 1", "ca" => "Àrea 1")
      end
    end

    it_behaves_like "a resource with taxonomies with no children"
    it_behaves_like "has resources"
    it_behaves_like "a single root taxonomy"
    it_behaves_like "can be converted to taxonomies"

    describe ".to_h" do
      let(:hash) { described_class.with(organization).to_h }
      let(:all_items) do
        [
          ["Area Type", "Area 1"],
          ["Area 2"]
        ]
      end

      it "returns the areas as taxonomies for each space" do
        expect(hash[:taxonomies]).to eq(
          "Area 2" => another_area.taxonomies,
          "Area Types" => {
            name: area_type.plural,
            origin: area_type.to_global_id.to_s,
            children: {
              "Area 1" => area.taxonomies
            },
            resources: {}
          }
        )
        expect(hash[:filters].count).to eq(3)
      end

      it "returns the filters for each space" do
        %w(assemblies participatory_processes initiatives).each do |space_manifest|
          expect(hash[:filters]).to include(
            {
              space_filter: true,
              space_manifest:,
              name: root_taxonomy_name,
              items: all_items,
              components: []
            }
          )
        end
      end
    end
  end
end
