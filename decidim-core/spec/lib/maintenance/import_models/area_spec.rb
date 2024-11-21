# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"

module Decidim::Maintenance::ImportModels
  describe Area do
    subject { area }

    let(:organization) { create(:organization) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let(:taxonomies) { [sub_taxonomy, another_taxonomy] }
    # avoid using factories for this test in case old models are removed
    let!(:area) { described_class.create!(name: { "en" => "Area 1", "ca" => "Àrea 1" }, decidim_organization_id: organization.id, area_type_id: area_type.id) }
    let!(:another_area) { described_class.create!(name: { "en" => "Area 2", "ca" => "Àrea 2" }, decidim_organization_id: organization.id) }
    let(:area_type) { AreaType.create!(name: { "en" => "Area Type", "ca" => "Tipus Area" }, plural: { "en" => "Area Types" }, decidim_organization_id: organization.id) }
    let!(:process) { create(:participatory_process, decidim_area_id: area.id, taxonomies:, organization:) }
    let(:external_organization) { create(:organization) }
    let(:external_taxonomy) { create(:taxonomy, :with_parent, organization: external_organization) }
    let!(:external_area) { described_class.create!(name: { "en" => "External Area" }, decidim_organization_id: external_organization.id) }
    let!(:external_process) { create(:participatory_process, organization: external_organization, decidim_area_id: external_area.id) }
    let(:root_taxonomy_name) { "~ #{I18n.t("decidim.admin.titles.areas")}" }

    describe "#name" do
      it "returns the name" do
        expect(subject.name).to eq(area.name)
      end
    end

    describe "#resources" do
      it "returns the resources" do
        expect(subject.resources).to eq({ process.to_global_id.to_s => process.title[I18n.locale.to_s] })
      end
    end

    describe "#taxonomies" do
      it "returns the taxonomies" do
        expect(subject.taxonomies).to eq(
          name: area.name,
          children: {},
          resources: subject.resources
        )
      end
    end

    describe ".to_taxonomies" do
      it "returns the areas" do
        expect(described_class.with(organization).to_taxonomies).to eq(
          root_taxonomy_name => described_class.to_h
        )
      end
    end

    describe ".to_h" do
      let(:hash) { described_class.with(organization).to_h }
      let(:all_items) do
        [
          ["Area Type", "Area 1"],
          ["Area 2"]
        ]
      end

      it "returns the scopes as taxonomies for each space" do
        expect(hash[:taxonomies]).to eq(
          another_area.name[I18n.locale.to_s] => another_area.taxonomies,
          area_type.name[I18n.locale.to_s] => {
            area.name[I18n.locale.to_s] => area.taxonomies
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
