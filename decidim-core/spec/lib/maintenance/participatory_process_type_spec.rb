# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

module Decidim::Maintenance
  describe ParticipatoryProcessType do
    subject { participatory_process_type }

    let(:organization) { create(:organization) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let(:taxonomies) { [sub_taxonomy, another_taxonomy] }
    # avoid using factories for this test in case old models are removed
    let(:participatory_process_type) { Decidim::Maintenance::ParticipatoryProcessType.create!(title: { "en" => "Participatory Process Type 1", "ca" => "Tipus de procés participatiu 1" }, decidim_organization_id: organization.id) }
    let!(:process) { create(:participatory_process, decidim_participatory_process_type_id: participatory_process_type.id, taxonomies:, organization:) }
    let(:external_organization) { create(:organization) }
    let(:external_taxonomy) { create(:taxonomy, :with_parent, organization: external_organization) }
    let!(:external_participatory_process_type) { Decidim::Maintenance::ParticipatoryProcessType.create!(title: { "en" => "External Participatory Process Type" }, decidim_organization_id: external_organization.id) }
    let!(:external_process) { create(:participatory_process, organization: external_organization, decidim_participatory_process_type_id: external_participatory_process_type.id) }

    describe "#name" do
      it "returns the title" do
        expect(subject.name).to eq(participatory_process_type.title)
      end
    end

    describe "#taxonomies" do
      it "returns the taxonomies" do
        expect(subject.taxonomies).to eq(
          name: participatory_process_type.title,
          children: [],
          resources: subject.resources
        )
      end
    end

    describe "#resources" do
      it "returns the resources" do
        expect(subject.resources).to eq({ process.to_global_id.to_s => process.title[I18n.locale.to_s] })
      end
    end

    describe ".to_taxonomies" do
      it "returns the participatory process types" do
        expect(described_class.with(organization).to_taxonomies).to eq(
          I18n.t("decidim.admin.titles.participatory_process_types") => described_class.to_a
        )
      end
    end

    describe ".to_a" do
      it "returns the participatory process types as taxonomies" do
        expect(described_class.with(organization).to_a).to eq(
          {
            taxonomies: { participatory_process_type.title[I18n.locale.to_s] => subject.taxonomies },
            filters: {
              I18n.t("decidim.admin.titles.participatory_process_types") => {
                space_filter: true,
                space_manifest: "participatory_processes",
                items: [[participatory_process_type.title[I18n.locale.to_s]]],
                components: []
              }
            }
          }
        )
      end
    end
  end
end
