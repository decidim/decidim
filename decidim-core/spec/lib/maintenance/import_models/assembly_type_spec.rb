# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"
require_relative "shared_examples"

module Decidim::Maintenance::ImportModels
  describe AssemblyType do
    subject { assembly_type }

    include_context "with taxonomy importer model context"
    # avoid using factories for this test in case old models are removed
    let(:assembly_type) { described_class.create!(title: { "en" => "Assembly Type 1", "ca" => "Tipus d'assemblea 1" }, decidim_organization_id: organization.id) }
    let!(:external_assembly_type) { described_class.create!(title: { "en" => "INVALID Assembly Type" }, decidim_organization_id: external_organization.id) }
    let(:root_taxonomy_name) { "~ Assemblies types" }
    let(:resource) { assembly }
    let(:space_manifest) { "assemblies" }

    before do
      described_class.add_resource_class("Decidim::Dev::DummyResource")
      assembly.update!(decidim_assemblies_type_id: assembly_type.id)
      external_assembly.update!(decidim_assemblies_type_id: external_assembly_type.id)
    end

    it_behaves_like "a resource with title"
    it_behaves_like "a resource with taxonomies with no children"
    it_behaves_like "has resources"
    it_behaves_like "a single root taxonomy"
    it_behaves_like "can be converted to taxonomies"
    it_behaves_like "a single root taxonomy with no children"
  end
end
