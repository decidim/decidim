# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

describe "Executing Decidim Taxonomy importer tasks" do
  let(:plan_file) { Rails.root.join("tmp/taxonomies/#{organization.host}_plan.json") }
  let(:organization) { create(:organization) }
  let(:decidim_organization_id) { organization.id }

  # avoid using factories for this test in case old models are removed
  let!(:process_type1) { Decidim::Maintenance::ImportModels::ParticipatoryProcessType.create!(title: { "en" => "Participatory Process Type 1", "ca" => "Tipus de procés participatiu 1" }, decidim_organization_id: organization.id) }
  let!(:process_type2) { Decidim::Maintenance::ImportModels::ParticipatoryProcessType.create!(title: { "en" => "Participatory Process Type 2", "ca" => "Tipus de procés participatiu 2" }, decidim_organization_id: organization.id) }

  let!(:assembly_type1) { Decidim::Maintenance::ImportModels::AssemblyType.create!(title: { "en" => "Assembly Type 1", "ca" => "Tipus d'assemblea 1" }, decidim_organization_id: organization.id) }
  let!(:assembly_type2) { Decidim::Maintenance::ImportModels::AssemblyType.create!(title: { "en" => "Assembly Type 2", "ca" => "Tipus d'assemblea 2" }, decidim_organization_id: organization.id) }

  let!(:scope) { Decidim::Maintenance::ImportModels::Scope.create!(name: { "en" => "Scope 1", "ca" => "Àmbit 1" }, code: "1", decidim_organization_id: organization.id) }
  let!(:another_scope) { Decidim::Maintenance::ImportModels::Scope.create!(name: { "en" => "Scope 2", "ca" => "Àmbit 2" }, code: "2", decidim_organization_id: organization.id) }
  let!(:sub_scope) { Decidim::Maintenance::ImportModels::Scope.create!(name: { "en" => "Scope 1 second level" }, code: "11", decidim_organization_id: organization.id, parent: scope) }

  let!(:participatory_process) { create(:participatory_process, title: { "en" => "Process" }, organization:, decidim_participatory_process_type_id: process_type1.id, decidim_scope_id: scope.id) }
  let!(:assembly) { create(:assembly, title: { "en" => "Assembly" }, organization:, decidim_assemblies_type_id: assembly_type1.id, decidim_scope_id: sub_scope.id) }
  let!(:dummy_component) { create(:dummy_component, name: { "en" => "Dummy component" }, participatory_space: assembly) }
  let!(:dummy_resource) { create(:dummy_resource, title: { "en" => "Dummy resource" }, component: dummy_component, scope: nil, decidim_scope_id: sub_scope.id) }
  let(:settings) { { scopes_enabled: true, scope_id: sub_scope.id } }

  before do
    scope.update!(part_of: [scope.id])
    another_scope.update!(part_of: [scope.id])
    sub_scope.update!(part_of: [scope.id, sub_scope.id])
    dummy_component.update!(settings:)
    Decidim::Maintenance::ImportModels::ApplicationRecord.add_resource_class("Decidim::Dev::DummyResource")
  end

  describe "rake decidim:taxonomies:make_plan", type: :task do
    let(:task) { Rake::Task["decidim:taxonomies:make_plan"] }

    it "creates a plan with the current categories, scopes and types" do # rubocop:disable RSpec/ExampleLength
      task.reenable
      task.invoke

      json_content = JSON.parse(File.read(plan_file))

      expect(json_content["organization"]["id"]).to eq(organization.id)
      expect(json_content["organization"]["host"]).to eq(organization.host)
      expect(json_content["organization"]["locale"]).to eq(organization.default_locale)
      expect(json_content["organization"]["name"]).to eq(organization.name[organization.default_locale])
      expect(json_content["existing_taxonomies"].count).to eq(0)

      process_type_roots = json_content["imported_taxonomies"]["decidim_participatory_process_types"]
      expect(process_type_roots.count).to eq(1)
      expect(process_type_roots.keys.first).to eq("~ Participatory process types")
      taxonomies = process_type_roots["~ Participatory process types"]["taxonomies"]
      expect(taxonomies.count).to eq(2)
      expect(taxonomies.keys).to contain_exactly("Participatory Process Type 1", "Participatory Process Type 2")
      expect(taxonomies["Participatory Process Type 1"]["name"]).to eq({ "en" => "Participatory Process Type 1", "ca" => "Tipus de procés participatiu 1" })
      expect(taxonomies["Participatory Process Type 1"]["resources"]).to eq({
                                                                              participatory_process.to_global_id.to_s => participatory_process.title[organization.default_locale]
                                                                            })
      expect(taxonomies["Participatory Process Type 2"]["resources"]).to eq({})
      expect(taxonomies["Participatory Process Type 2"]["name"]).to eq({ "en" => "Participatory Process Type 2", "ca" => "Tipus de procés participatiu 2" })

      expect(process_type_roots["~ Participatory process types"]["filters"].count).to eq(1)
      expect(process_type_roots["~ Participatory process types"]["filters"].first["name"]).to eq("~ Participatory process types")
      expect(process_type_roots["~ Participatory process types"]["filters"].first["space_filter"]).to be(true)
      expect(process_type_roots["~ Participatory process types"]["filters"].first["space_manifest"]).to eq("participatory_processes")
      expect(process_type_roots["~ Participatory process types"]["filters"].first["items"]).to contain_exactly(["Participatory Process Type 1"], ["Participatory Process Type 2"])
      expect(process_type_roots["~ Participatory process types"]["filters"].first["components"]).to eq([])

      assembly_types_roots = json_content["imported_taxonomies"]["decidim_assemblies_types"]
      expect(assembly_types_roots.count).to eq(1)
      expect(assembly_types_roots.keys.first).to eq("~ Assemblies types")
      taxonomies = assembly_types_roots["~ Assemblies types"]["taxonomies"]
      expect(taxonomies.count).to eq(2)
      expect(taxonomies.keys).to contain_exactly("Assembly Type 1", "Assembly Type 2")
      expect(taxonomies["Assembly Type 1"]["name"]).to eq({ "en" => "Assembly Type 1", "ca" => "Tipus d'assemblea 1" })
      expect(taxonomies["Assembly Type 1"]["resources"]).to eq({ assembly.to_global_id.to_s => assembly.title[organization.default_locale] })
      expect(taxonomies["Assembly Type 2"]["resources"]).to eq({})
      expect(taxonomies["Assembly Type 2"]["name"]).to eq({ "en" => "Assembly Type 2", "ca" => "Tipus d'assemblea 2" })

      expect(assembly_types_roots["~ Assemblies types"]["filters"].count).to eq(1)
      expect(assembly_types_roots["~ Assemblies types"]["filters"].first["name"]).to eq("~ Assemblies types")
      expect(assembly_types_roots["~ Assemblies types"]["filters"].first["space_filter"]).to be(true)
      expect(assembly_types_roots["~ Assemblies types"]["filters"].first["space_manifest"]).to eq("assemblies")
      expect(assembly_types_roots["~ Assemblies types"]["filters"].first["items"]).to contain_exactly(["Assembly Type 1"], ["Assembly Type 2"])
      expect(assembly_types_roots["~ Assemblies types"]["filters"].first["components"]).to eq([])

      scope_roots = json_content["imported_taxonomies"]["decidim_scopes"]
      expect(scope_roots.count).to eq(1)
      taxonomies = scope_roots["~ Scopes"]["taxonomies"]
      expect(taxonomies.keys).to contain_exactly("Scope 1", "Scope 2")
      expect(taxonomies["Scope 1"]["children"]["Scope 1 second level"]["name"]).to eq("en" => "Scope 1 second level")
      expect(taxonomies["Scope 1"]["children"]["Scope 1 second level"]["resources"]).to eq({
                                                                                             assembly.to_global_id.to_s => assembly.title[organization.default_locale],
                                                                                             dummy_resource.to_global_id.to_s => "Dummy resource"
                                                                                           })
      expect(scope_roots["~ Scopes"]["filters"].count).to eq(5)
      expect(scope_roots["~ Scopes"]["filters"]).to include(
        "space_filter" => true,
        "space_manifest" => "participatory_processes",
        "name" => "~ Scopes",
        "items" => [["Scope 1"], ["Scope 1", "Scope 1 second level"], ["Scope 2"]],
        "components" => []
      )
      expect(scope_roots["~ Scopes"]["filters"]).to include(
        "space_filter" => true,
        "space_manifest" => "assemblies",
        "name" => "~ Scopes",
        "items" => [["Scope 1"], ["Scope 1", "Scope 1 second level"], ["Scope 2"]],
        "components" => []
      )
      expect(scope_roots["~ Scopes"]["filters"]).to include(
        "space_filter" => false,
        "space_manifest" => "assemblies",
        "name" => "~ Scopes",
        "internal_name" => "~ Scopes: Dummy component",
        "items" => [["Scope 1", "Scope 1 second level"]],
        "components" => [dummy_component.to_global_id.to_s]
      )

      check_message_printed("Creating a plan for organization #{decidim_organization_id}")
      check_message_printed("...Exporting taxonomies for decidim_participatory_process_types")
      check_message_printed("...Exporting taxonomies for decidim_assemblies_types")
      check_message_printed("...Exporting taxonomies for decidim_scopes")
      check_message_printed("Plan created")
    end
  end

  describe "rake decidim:taxonomies:import_all_plans", type: :task do
    let(:task) { Rake::Task["decidim:taxonomies:import_all_plans"] }

    before do
      FileUtils.rm_rf(Rails.root.join("tmp/taxonomies/"))
      Rake::Task["decidim:taxonomies:make_plan"].reenable
      Rake::Task["decidim:taxonomies:make_plan"].invoke
    end

    it "imports the plan for all organizations" do # rubocop:disable RSpec/ExampleLength
      expect { task.invoke }.to change(Decidim::Taxonomy, :count).by(10)

      check_message_printed("Importing taxonomies and filters for organization #{decidim_organization_id}")

      check_message_printed(<<~MSG)
        ...Importing 1 root taxonomies from decidim_participatory_process_types
          - Root taxonomy: ~ Participatory process types
            Taxonomy items: 2
            Filters: 1
              - Filter name: ~ Participatory process types
                Internal name: -
                Manifest: participatory_processes
                Space filter: true
                Items: 2
                Components: 0
            Created taxonomies: 3
              - ~ Participatory process types
              - Participatory Process Type 1
              - Participatory Process Type 2
            Created filters: 1
              - participatory_processes: ~ Participatory process types: 2 items
            Assigned resources: 1
              - Participatory Process Type 1:
                - #{participatory_process.to_global_id}
            Failed resources: 0
            Failed components: 0
      MSG

      check_message_printed(<<~MSG)
        ...Importing 1 root taxonomies from decidim_assemblies_types
          - Root taxonomy: ~ Assemblies types
            Taxonomy items: 2
            Filters: 1
              - Filter name: ~ Assemblies types
                Internal name: -
                Manifest: assemblies
                Space filter: true
                Items: 2
                Components: 0
            Created taxonomies: 3
              - ~ Assemblies types
              - Assembly Type 1
              - Assembly Type 2
            Created filters: 1
              - assemblies: ~ Assemblies types: 2 items
            Assigned resources: 1
              - Assembly Type 1:
                - #{assembly.to_global_id}
            Failed resources: 0
            Failed components: 0
      MSG

      check_message_printed(<<~MSG)
        ...Importing 1 root taxonomies from decidim_scopes
          - Root taxonomy: ~ Scopes
            Taxonomy items: 2
            Filters: 5
              - Filter name: ~ Scopes
                Internal name: -
                Manifest: assemblies
                Space filter: true
                Items: 3
                Components: 0
              - Filter name: ~ Scopes
                Internal name: ~ Scopes: Dummy component
                Manifest: assemblies
                Space filter: false
                Items: 1
                Components: 1
              - Filter name: ~ Scopes
                Internal name: -
                Manifest: participatory_processes
                Space filter: true
                Items: 3
                Components: 0
              - Filter name: ~ Scopes
                Internal name: -
                Manifest: conferences
                Space filter: true
                Items: 3
                Components: 0
              - Filter name: ~ Scopes
                Internal name: -
                Manifest: initiatives
                Space filter: true
                Items: 3
                Components: 0
            Created taxonomies: 4
              - ~ Scopes
              - Scope 1
              - Scope 1 second level
              - Scope 2
            Created filters: 5
              - assemblies: ~ Scopes: 3 items
              - assemblies: ~ Scopes: Dummy component: 1 items
              - participatory_processes: ~ Scopes: 3 items
              - conferences: ~ Scopes: 3 items
              - initiatives: ~ Scopes: 3 items
            Assigned resources: 2
              - Scope 1:
                - #{participatory_process.to_global_id}
              - Scope 1 second level:
                - #{assembly.to_global_id}
                - #{dummy_resource.to_global_id}
            Failed resources: 0
            Failed components: 0
      MSG

      check_message_printed("Taxonomies and filters imported successfully.")
    end
  end
end
