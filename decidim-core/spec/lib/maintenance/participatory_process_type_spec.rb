# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

module Decidim::Maintenance
  describe ParticipatoryProcessType do
    subject { described_class.last }

    let!(:participatory_process_type) { create(:participatory_process_type, organization:) }
    let(:organization) { create(:organization) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let(:taxonomies) { [sub_taxonomy, another_taxonomy] }
    let!(:process) { create(:participatory_process, participatory_process_type:, taxonomies:, organization:) }

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
        expect(described_class.to_taxonomies).to eq(
          I18n.t("decidim.admin.titles.participatory_process_types") => described_class.to_a
        )
      end
    end

    describe ".to_a" do
      it "returns the participatory process types as taxonomies" do
        expect(described_class.to_a).to eq(
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
