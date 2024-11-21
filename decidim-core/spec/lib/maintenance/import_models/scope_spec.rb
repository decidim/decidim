# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"

module Decidim::Maintenance::ImportModels
  describe Scope do
    subject { scope }

    let(:organization) { create(:organization) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let(:taxonomies) { [sub_taxonomy, another_taxonomy] }
    # avoid using factories for this test in case old models are removed
    let(:scope) { described_class.create!(name: { "en" => "Scope 1", "ca" => "Àmbit 1" }, code: "1", decidim_organization_id: organization.id) }
    let(:another_scope) { described_class.create!(name: { "en" => "Scope 2", "ca" => "Àmbit 2" }, code: "2", decidim_organization_id: organization.id) }
    let(:sub2_scope) { described_class.create!(name: { "en" => "Scope 1 second level" }, code: "11", decidim_organization_id: organization.id, parent: scope) }
    let(:sub3_scope) { described_class.create!(name: { "en" => "Scope 1 third level" }, code: "111", decidim_organization_id: organization.id, parent: sub2_scope) }
    let!(:sub4_scope) { described_class.create!(name: { "en" => "Scope 1 fourth level" }, code: "1111", decidim_organization_id: organization.id, parent: sub3_scope) }
    let!(:sub5_scope) { described_class.create!(name: { "en" => "Scope 1 fifth level" }, code: "11111", decidim_organization_id: organization.id, parent: sub4_scope) }
    let!(:assembly) { create(:assembly, taxonomies:, title: { "en" => "Assembly" }, organization:, decidim_scope_id: sub2_scope.id, scopes_enabled: space_scopes_enabled) }
    let(:space_scopes_enabled) { true }
    let!(:participatory_process) { create(:participatory_process, title: { "en" => "Participatory Process" }, organization:, decidim_scope_id: sub2_scope.id) }
    let!(:dummy_component) { create(:dummy_component, name: { "en" => "Dummy Component" }, participatory_space: assembly) }
    let(:component_scope_enabled) { true }
    let!(:dummy_resource) { create(:dummy_resource, title: { "en" => "Dummy Resource" }, component: dummy_component, scope: nil, decidim_scope_id: sub4_scope.id) }

    let(:external_organization) { create(:organization, name: { "en" => "INVALID Organization" }) }
    let(:external_scope) { described_class.create!(name: { "en" => "INVALID scope" }, code: "3", decidim_organization_id: external_organization.id) }
    let!(:external_assembly) { create(:assembly, title: { "en" => "INVALID Assembly" }, organization: external_organization, decidim_scope_id: external_scope.id) }

    let(:settings) { { scopes_enabled: component_scope_enabled, scope_id: sub3_scope.id } }
    let(:root_taxonomy_name) { "~ #{I18n.t("decidim.admin.titles.scopes")}" }

    before do
      # update part_of for scopes
      scope.update!(part_of: [scope.id])
      another_scope.update!(part_of: [scope.id])
      sub2_scope.update!(part_of: [scope.id, sub2_scope.id])
      sub3_scope.update!(part_of: [scope.id, sub2_scope.id, sub3_scope.id])
      sub4_scope.update!(part_of: [scope.id, sub2_scope.id, sub3_scope.id, sub4_scope.id])
      sub5_scope.update!(part_of: [scope.id, sub2_scope.id, sub3_scope.id, sub4_scope.id, sub5_scope.id])
      dummy_component.update!(settings:)
      described_class.add_resource_class("Decidim::Dev::DummyResource")
    end

    describe "#name" do
      it "returns the name" do
        expect(sub2_scope.name).to eq("en" => "Scope 1 second level")
      end
    end

    describe "#resources" do
      it "returns the resources" do
        expect(sub2_scope.resources).to eq({
                                             assembly.to_global_id.to_s => assembly.title[I18n.locale.to_s],
                                             participatory_process.to_global_id.to_s => participatory_process.title[I18n.locale.to_s]
                                           })

        expect(sub4_scope.resources).to eq({ dummy_resource.to_global_id.to_s => dummy_resource.title[I18n.locale.to_s] })
      end
    end

    describe "#taxonomies" do
      it "returns the taxonomies" do
        expect(scope.taxonomies).to eq(
          name: { "en" => "Scope 1", "ca" => "Àmbit 1" },
          children: {
            "Scope 1 second level" => {
              name: { "en" => "Scope 1 second level" },
              children: {
                "Scope 1 third level" => {
                  name: { "en" => "Scope 1 third level" },
                  children: {
                    "Scope 1 third level > Scope 1 fourth level" => {
                      name: { "en" => "Scope 1 third level > Scope 1 fourth level" },
                      children: {},
                      resources: sub4_scope.resources
                    },
                    "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level" => {
                      name: { "en" => "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level" },
                      children: {},
                      resources: {}
                    }
                  },
                  resources: {}
                }
              },
              resources: sub2_scope.resources
            }
          },
          resources: {}
        )
      end
    end

    describe ".to_taxonomies" do
      it "returns the participatory Scopes" do
        expect(described_class.with(organization).to_taxonomies).to eq(
          root_taxonomy_name => described_class.to_h
        )
      end
    end

    describe ".to_h" do
      let(:all_items) do
        [
          ["Scope 1"],
          [
            "Scope 1",
            "Scope 1 second level"
          ],
          [
            "Scope 1",
            "Scope 1 second level",
            "Scope 1 third level"
          ],
          [
            "Scope 1",
            "Scope 1 second level",
            "Scope 1 third level",
            "Scope 1 third level > Scope 1 fourth level"
          ],
          [
            "Scope 1",
            "Scope 1 second level",
            "Scope 1 third level",
            "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level"
          ],
          ["Scope 2"]
        ]
      end
      let(:hash) { described_class.with(organization).to_h }

      it "returns the scopes as taxonomies for each space" do
        expect(hash[:taxonomies]).to eq(
          scope.name[I18n.locale.to_s] => scope.taxonomies,
          another_scope.name[I18n.locale.to_s] => another_scope.taxonomies
        )
        expect(hash[:filters].count).to eq(5)
      end

      it "returns the filters for each space" do
        %w(assemblies participatory_processes conferences initiatives).each do |space_manifest|
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

      it "returns the filters for each component" do
        expect(hash[:filters]).to include(
          {
            space_filter: false,
            space_manifest: "assemblies",
            name: root_taxonomy_name,
            internal_name: "#{root_taxonomy_name}: Dummy Component",
            items: [
              [
                "Scope 1",
                "Scope 1 second level",
                "Scope 1 third level"
              ],
              [
                "Scope 1",
                "Scope 1 second level",
                "Scope 1 third level",
                "Scope 1 third level > Scope 1 fourth level"
              ],
              [
                "Scope 1",
                "Scope 1 second level",
                "Scope 1 third level",
                "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level"
              ]
            ],
            components: [dummy_component.to_global_id.to_s]
          }
        )
      end
    end
  end
end
