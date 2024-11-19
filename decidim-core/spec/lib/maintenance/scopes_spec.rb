# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

module Decidim::Maintenance
  describe Scope do
    let(:organization) { create(:organization) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let(:taxonomies) { [sub_taxonomy, another_taxonomy] }
    # avoid using factories for this test in case old models are removed
    let(:scope) { Decidim::Maintenance::Scope.create!(name: { "en" => "Scope 1", "ca" => "Àmbit 1" }, code: "1", decidim_organization_id: organization.id) }
    let(:another_scope) { Decidim::Maintenance::Scope.create!(name: { "en" => "Scope 2", "ca" => "Àmbit 2" }, code: "2", decidim_organization_id: organization.id) }
    let(:sub2_scope) { Decidim::Maintenance::Scope.create!(name: { "en" => "Scope 1 second level" }, code: "11", decidim_organization_id: organization.id, parent: scope) }
    let(:sub3_scope) { Decidim::Maintenance::Scope.create!(name: { "en" => "Scope 1 third level" }, code: "111", decidim_organization_id: organization.id, parent: sub2_scope) }
    let!(:sub4_scope) { Decidim::Maintenance::Scope.create!(name: { "en" => "Scope 1 fourth level" }, code: "1111", decidim_organization_id: organization.id, parent: sub3_scope) }
    let!(:sub5_scope) { Decidim::Maintenance::Scope.create!(name: { "en" => "Scope 1 fifth level" }, code: "11111", decidim_organization_id: organization.id, parent: sub4_scope) }
    let!(:assembly) { create(:assembly, taxonomies:, organization:, decidim_scope_id: sub2_scope.id) }
    let!(:participatory_process) { create(:participatory_process, organization:, decidim_scope_id: sub2_scope.id) }

    describe "#name" do
      it "returns the name" do
        expect(sub2_scope.name).to eq(scope.name)
      end
    end

    describe "#resources" do
      it "returns the resources" do
        expect(sub2_scope.resources).to eq({
                                             assembly.to_global_id.to_s => assembly.title[I18n.locale.to_s],
                                             participatory_process.to_global_id.to_s => participatory_process.title[I18n.locale.to_s]
                                           })
      end
    end

    describe "#taxonomies" do
      it "returns the taxonomies" do
        expect(scope.taxonomies).to eq(
          name: { "en" => "Scope 1", "ca" => "Àmbit 1" },
          children: [
            {
              name: { "en" => "Scope 1 second level" },
              children: [{
                name: { "en" => "Scope 1 third level" },
                children: [
                  {
                    name: { "en" => "Scope 1 third level > Scope 1 fourth level" },
                    children: [],
                    resources: {}
                  },
                  {
                    name: { "en" => "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level" },
                    children: [],
                    resources: {}
                  }
                ],
                resources: {}
              }],
              resources: sub2_scope.resources
            }
          ],
          resources: {}
        )
      end
    end

    describe ".to_taxonomies" do
      it "returns the participatory Scopes" do
        expect(described_class.to_taxonomies).to eq(
          I18n.t("decidim.scopes.scopes") => described_class.to_a
        )
      end
    end

    describe ".to_a" do
      it "returns the scopes as taxonomies and filters for each space" do
        expect(described_class.to_a).to eq(
          {
            taxonomies: { scope.title[I18n.locale.to_s] => subject.taxonomies },
            filters: {
              I18n.t("decidim.scopes.scopes") => {
                space_filter: true,
                space_manifest: "assemblies",
                items: [[scope.title[I18n.locale.to_s]]],
                components: []
              }
            }
          }
        )
      end
    end
  end
end
