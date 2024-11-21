# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"

module Decidim::Maintenance::ImportModels
  describe AssemblyType do
    subject { assembly_type }

    let(:organization) { create(:organization) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let(:taxonomies) { [sub_taxonomy, another_taxonomy] }
    # avoid using factories for this test in case old models are removed
    let(:assembly_type) { described_class.create!(title: { "en" => "Assembly Type 1", "ca" => "Tipus d'assemblea 1" }, decidim_organization_id: organization.id) }
    let!(:assembly) { create(:assembly, taxonomies:, organization:, decidim_assemblies_type_id: assembly_type.id) }
    let(:external_organization) { create(:organization) }
    let(:external_taxonomy) { create(:taxonomy, :with_parent, organization: external_organization) }
    let!(:external_assembly_type) { described_class.create!(title: { "en" => "External Assembly Type" }, decidim_organization_id: external_organization.id) }
    let!(:external_assembly) { create(:assembly, organization: external_organization, decidim_assemblies_type_id: external_assembly_type.id) }
    let(:root_taxonomy_name) { "~ Assemblies types" }

    describe "#name" do
      it "returns the title" do
        expect(subject.name).to eq(assembly_type.title)
      end
    end

    describe "#taxonomies" do
      it "returns the taxonomies" do
        expect(subject.taxonomies).to eq(
          name: assembly_type.title,
          children: {},
          resources: subject.resources
        )
      end
    end

    describe "#resources" do
      it "returns the resources" do
        expect(subject.resources).to eq({ assembly.to_global_id.to_s => assembly.title[I18n.locale.to_s] })
      end
    end

    describe ".to_taxonomies" do
      it "returns the participatory assembly types" do
        expect(described_class.with(organization).to_taxonomies).to eq(
          root_taxonomy_name => described_class.to_h
        )
      end
    end

    describe ".to_h" do
      it "returns the participatory assembly types as taxonomies" do
        expect(described_class.with(organization).to_h).to eq(
          {
            taxonomies: { assembly_type.title[I18n.locale.to_s] => subject.taxonomies },
            filters: [
              {
                name: root_taxonomy_name,
                space_filter: true,
                space_manifest: "assemblies",
                items: [[assembly_type.title[I18n.locale.to_s]]],
                components: []
              }
            ]
          }
        )
      end
    end
  end
end
