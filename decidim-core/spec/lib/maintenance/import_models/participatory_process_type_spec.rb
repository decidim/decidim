# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"
require_relative "shared_examples"

module Decidim::Maintenance::ImportModels
  describe ParticipatoryProcessType do
    subject { participatory_process_type }

    include_context "with taxonomy importer model context"
    # avoid using factories for this test in case old models are removed
    let(:participatory_process_type) { described_class.create!(title: { "en" => "Participatory Process Type 1", "ca" => "Tipus de procés participatiu 1" }, decidim_organization_id: organization.id) }

    let!(:external_participatory_process_type) { described_class.create!(title: { "en" => "External Participatory Process Type" }, decidim_organization_id: external_organization.id) }
    let(:root_taxonomy_name) { "~ Participatory process types" }
    let(:resource) { participatory_process }
    let(:space_manifest) { "participatory_processes" }

    before do
      described_class.add_resource_class("Decidim::Dev::DummyResource")
      participatory_process.update!(decidim_participatory_process_type_id: participatory_process_type.id)
      external_participatory_process.update!(decidim_participatory_process_type_id: external_participatory_process_type.id)
    end

    it_behaves_like "a resource with title"
    it_behaves_like "a resource with taxonomies with no children"
    it_behaves_like "has resources"
    it_behaves_like "a single root taxonomy"
    it_behaves_like "can be converted to taxonomies"
    it_behaves_like "a single root taxonomy with no children"
  end
end
