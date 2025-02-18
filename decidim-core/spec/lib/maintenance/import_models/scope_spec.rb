# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"
require_relative "shared_examples"

module Decidim::Maintenance::ImportModels
  describe Scope do
    subject { scope }

    include_context "with taxonomy importer model context"
    # avoid using factories for this test in case old models are removed
    let(:scope) { described_class.create!(name: { "en" => "Scope 1", "ca" => "Àmbit 1" }, code: "1", decidim_organization_id: organization.id) }
    let(:another_scope) { described_class.create!(name: { "en" => "Scope 2", "ca" => "Àmbit 2" }, code: "2", decidim_organization_id: organization.id) }
    let(:sub2_scope) { described_class.create!(name: { "en" => "Scope 1 second level" }, code: "11", decidim_organization_id: organization.id, parent: scope) }
    let(:sub3_scope) { described_class.create!(name: { "en" => "Scope 1 third level" }, code: "111", decidim_organization_id: organization.id, parent: sub2_scope) }
    let!(:sub4_scope) { described_class.create!(name: { "en" => "Scope 1 fourth level" }, code: "1111", decidim_organization_id: organization.id, parent: sub3_scope) }
    let!(:sub5_scope) { described_class.create!(name: { "en" => "Scope 1 fifth level" }, code: "11111", decidim_organization_id: organization.id, parent: sub4_scope) }
    let(:external_scope) { described_class.create!(name: { "en" => "INVALID scope" }, code: "3", decidim_organization_id: external_organization.id) }
    let(:settings) { { scopes_enabled: component_scope_enabled, scope_id: sub3_scope.id } }
    let(:space_scopes_enabled) { true }
    let(:component_scope_enabled) { true }
    let(:root_taxonomy_name) { "~ Scopes" }

    before do
      described_class.add_resource_class("Decidim::Dev::DummyResource")
      # update part_of for scopes
      scope.update!(part_of: [scope.id])
      another_scope.update!(part_of: [scope.id])
      sub2_scope.update!(part_of: [scope.id, sub2_scope.id])
      sub3_scope.update!(part_of: [scope.id, sub2_scope.id, sub3_scope.id])
      sub4_scope.update!(part_of: [scope.id, sub2_scope.id, sub3_scope.id, sub4_scope.id])
      sub5_scope.update!(part_of: [scope.id, sub2_scope.id, sub3_scope.id, sub4_scope.id, sub5_scope.id])
      assembly.update!(decidim_scope_id: sub2_scope.id, scopes_enabled: space_scopes_enabled)
      participatory_process.update!(decidim_scope_id: sub2_scope.id)
      # as scope settings are disabled now, we need to update the settings directly as it was already there
      # rubocop:disable Rails/SkipsModelValidations
      dummy_component.update_column(:settings, {
                                      "global" => settings
                                    })
      # rubocop:enable Rails/SkipsModelValidations
      dummy_resource.update!(decidim_scope_id: sub4_scope.id) if dummy_resource
      external_assembly.update!(decidim_scope_id: external_scope.id, scopes_enabled: true)
    end

    describe "#name" do
      it "returns the name" do
        expect(scope.name).to eq("en" => "Scope 1", "ca" => "Àmbit 1")
        expect(sub2_scope.name).to eq("en" => "Scope 1 second level")
        expect(sub3_scope.name).to eq("en" => "Scope 1 third level")
        expect(sub4_scope.name).to eq("en" => "Scope 1 fourth level")
        expect(sub5_scope.name).to eq("en" => "Scope 1 fifth level")
      end

      it "returns the full name" do
        expect(scope.full_name).to eq("en" => "Scope 1", "ca" => "Àmbit 1")
        expect(sub2_scope.full_name).to eq("en" => "Scope 1 second level")
        expect(sub3_scope.full_name).to eq("en" => "Scope 1 third level")
        expect(sub4_scope.full_name).to eq("en" => "Scope 1 third level > Scope 1 fourth level")
        expect(sub5_scope.full_name).to eq("en" => "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level")
      end

      it "returns all names hierarchy" do
        expect(scope.all_names).to eq(["Scope 1"])
        expect(sub2_scope.all_names).to eq(["Scope 1", "Scope 1 second level"])
        expect(sub3_scope.all_names).to eq(["Scope 1", "Scope 1 second level", "Scope 1 third level"])
        expect(sub4_scope.all_names).to eq(["Scope 1", "Scope 1 second level", "Scope 1 third level > Scope 1 fourth level"])
        expect(sub5_scope.all_names).to eq(["Scope 1", "Scope 1 second level", "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level"])
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
          origin: scope.to_global_id.to_s,
          children: {
            "Scope 1 second level" => {
              name: { "en" => "Scope 1 second level" },
              origin: sub2_scope.to_global_id.to_s,
              children: {
                "Scope 1 third level" => {
                  name: { "en" => "Scope 1 third level" },
                  origin: sub3_scope.to_global_id.to_s,
                  children: {},
                  resources: {}
                },
                "Scope 1 third level > Scope 1 fourth level" => {
                  name: { "en" => "Scope 1 third level > Scope 1 fourth level" },
                  origin: sub4_scope.to_global_id.to_s,
                  children: {},
                  resources: sub4_scope.resources
                },
                "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level" => {
                  name: { "en" => "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level" },
                  origin: sub5_scope.to_global_id.to_s,
                  children: {},
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
      it_behaves_like "a single root taxonomy"
      it_behaves_like "can be converted to taxonomies"
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
            "Scope 1 third level > Scope 1 fourth level"
          ],
          [
            "Scope 1",
            "Scope 1 second level",
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
        expect(hash[:filters].count).to eq(2)
      end

      it "returns the filters for each space" do
        expect(hash[:filters]).to include(
          {
            participatory_space_manifests: %w(assemblies participatory_processes conferences initiatives),
            name: root_taxonomy_name,
            items: all_items,
            components: []
          }
        )
      end

      it "returns the filters for each component" do
        expect(hash[:filters]).to include(
          {
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
                "Scope 1 third level > Scope 1 fourth level"
              ],
              [
                "Scope 1",
                "Scope 1 second level",
                "Scope 1 third level > Scope 1 fourth level > Scope 1 fifth level"
              ]
            ],
            components: [dummy_component.to_global_id.to_s]
          }
        )
      end

      context "and a component has no taxonomy filters" do
        let!(:dummy_component) { create(:post_component, name: { "en" => "Another Dummy Component" }, participatory_space: assembly) }
        let(:dummy_resource) { nil }

        it "Skips the component" do
          expect(hash[:filters].count).to eq(1)

          hash[:filters].each do |filter|
            expect(filter[:participatory_space_manifests]).to be_present
            expect(filter[:components]).to be_empty
          end
        end
      end
    end
  end
end
