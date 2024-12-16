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

  let!(:area) { Decidim::Maintenance::ImportModels::Area.create!(name: { "en" => "Area 1", "ca" => "Àrea 1" }, decidim_organization_id: organization.id) }

  let!(:category) { Decidim::Maintenance::ImportModels::Category.create!(name: { "en" => "Category 1", "ca" => "Categoria 1" }, participatory_space: assembly) }
  let!(:subcategory) { Decidim::Maintenance::ImportModels::Category.create!(name: { "en" => "Sub Category 1", "ca" => "Subcategoria 1" }, parent: category, participatory_space: assembly) }
  let!(:another_category) { Decidim::Maintenance::ImportModels::Category.create!(name: { "en" => "Another Category 2", "ca" => "Una Altra Categoria 2" }, participatory_space: participatory_process) }

  let!(:participatory_process) { create(:participatory_process, title: { "en" => "Process" }, organization:, decidim_participatory_process_type_id: process_type1.id, decidim_scope_id: another_scope.id) }
  let!(:assembly) { create(:assembly, title: { "en" => "Assembly" }, organization:, decidim_assemblies_type_id: assembly_type1.id, decidim_scope_id: scope.id, decidim_area_id: area.id) }

  let!(:dummy_component) { create(:dummy_component, name: { "en" => "Dummy component" }, participatory_space: assembly) }
  let!(:dummy_resource) { create(:dummy_resource, title: { "en" => "Dummy resource" }, component: dummy_component, scope: nil, decidim_scope_id: sub_scope.id) }
  let!(:categorization) { Decidim::Maintenance::ImportModels::Categorization.create!(category:, categorizable: dummy_resource) }
  let!(:metric) { create(:metric, organization:, decidim_category_id: subcategory.id, participatory_space: assembly, related_object: dummy_resource) }
  let(:settings) { { scopes_enabled: true, scope_id: sub_scope.id } }

  before do
    allow($stdout).to receive(:puts).and_call_original

    scope.update!(part_of: [scope.id])
    another_scope.update!(part_of: [scope.id])
    sub_scope.update!(part_of: [scope.id, sub_scope.id])
    dummy_component.update!(settings:)
    Decidim::Maintenance::ImportModels::Scope.add_resource_class("Decidim::Dev::DummyResource")
  end

  describe "rake decidim:taxonomies:make_plan", type: :task do
    let(:task) { Rake::Task["decidim:taxonomies:make_plan"] }

    it "creates a plan with the current categories, areas, scopes and types" do # rubocop:disable RSpec/ExampleLength
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
                                                                                             dummy_resource.to_global_id.to_s => "Dummy resource"
                                                                                           })
      expect(taxonomies["Scope 1"]["resources"]).to eq({
                                                         assembly.to_global_id.to_s => "Assembly"
                                                       })
      expect(taxonomies["Scope 2"]["children"]).to eq({})
      expect(taxonomies["Scope 2"]["resources"]).to eq({
                                                         participatory_process.to_global_id.to_s => "Process"
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

      areas_roots = json_content["imported_taxonomies"]["decidim_areas"]
      expect(areas_roots.count).to eq(1)
      expect(areas_roots.keys.first).to eq("~ Areas")
      expect(areas_roots["~ Areas"]["taxonomies"].keys).to contain_exactly("Area 1")
      expect(areas_roots["~ Areas"]["taxonomies"]["Area 1"]["resources"]).to eq({
                                                                                  assembly.to_global_id.to_s => "Assembly"
                                                                                })
      expect(areas_roots["~ Areas"]["filters"].count).to eq(3)
      expect(areas_roots["~ Areas"]["filters"]).to include(
        "space_filter" => true,
        "space_manifest" => "assemblies",
        "name" => "~ Areas",
        "items" => [["Area 1"]],
        "components" => []
      )
      expect(areas_roots["~ Areas"]["filters"]).to include(
        "space_filter" => true,
        "space_manifest" => "participatory_processes",
        "name" => "~ Areas",
        "items" => [["Area 1"]],
        "components" => []
      )
      expect(areas_roots["~ Areas"]["filters"]).to include(
        "space_filter" => true,
        "space_manifest" => "initiatives",
        "name" => "~ Areas",
        "items" => [["Area 1"]],
        "components" => []
      )

      categories_roots = json_content["imported_taxonomies"]["decidim_categories"]
      expect(categories_roots.count).to eq(1)
      expect(categories_roots.keys.first).to eq("~ Categories")
      cat_taxonomies = categories_roots["~ Categories"]["taxonomies"]
      expect(cat_taxonomies.keys).to contain_exactly("Assembly: Assembly", "Participatory process: Process")
      expect(cat_taxonomies["Assembly: Assembly"]["name"]).to eq("en" => "Assembly: Assembly")
      expect(cat_taxonomies["Assembly: Assembly"]["children"]["Category 1"]["name"]).to eq("en" => "Category 1", "ca" => "Categoria 1")
      expect(cat_taxonomies["Assembly: Assembly"]["children"]["Category 1"]["resources"]).to eq({
                                                                                                  dummy_resource.to_global_id.to_s => "Dummy resource"
                                                                                                })
      expect(cat_taxonomies["Assembly: Assembly"]["children"]["Category 1"]["children"]["Sub Category 1"]["name"]).to eq("en" => "Sub Category 1", "ca" => "Subcategoria 1")
      expect(cat_taxonomies["Participatory process: Process"]["name"]).to eq("en" => "Participatory process: Process")
      expect(cat_taxonomies["Participatory process: Process"]["children"]["Another Category 2"]["name"]).to eq("en" => "Another Category 2", "ca" => "Una Altra Categoria 2")
      expect(categories_roots["~ Categories"]["filters"].count).to eq(1)
      expect(categories_roots["~ Categories"]["filters"]).to include(
        "space_filter" => false,
        "space_manifest" => "assemblies",
        "internal_name" => "Assembly: Assembly",
        "name" => "~ Categories",
        "items" => [["Assembly: Assembly", "Category 1"],
                    ["Assembly: Assembly", "Category 1", "Sub Category 1"]],
        "components" => [
          dummy_component.to_global_id.to_s
        ]
      )

      check_message_printed("Creating a plan for organization #{decidim_organization_id}")
      check_message_printed("...Exporting taxonomies for decidim_participatory_process_types")
      check_message_printed("...Exporting taxonomies for decidim_assemblies_types")
      check_message_printed("...Exporting taxonomies for decidim_scopes")
      check_message_printed("...Exporting taxonomies for decidim_areas")
      check_message_printed("...Exporting taxonomies for decidim_categories")
      check_message_printed("Plan created")
    end

    context "when the IMPORT env var is set" do
      before do
        allow(ENV).to receive(:fetch).with("IMPORTS", "ParticipatoryProcessType AssemblyType Scope Area Category").and_return("Scope Area")
      end

      it "creates a plan and imports it" do
        task.reenable
        task.invoke

        check_message_printed("Creating a plan for organization #{decidim_organization_id}")
        expect($stdout.string).not_to include("...Exporting taxonomies for decidim_participatory_process_types")
        expect($stdout.string).not_to include("...Exporting taxonomies for decidim_assemblies_types")
        check_message_printed("...Exporting taxonomies for decidim_scopes")
        check_message_printed("...Exporting taxonomies for decidim_areas")
        expect($stdout.string).not_to include("...Exporting taxonomies for decidim_categories")
        check_message_printed("Plan created")
      end
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
      expect { task.invoke }.to change(Decidim::Taxonomy, :count).by(18)

      check_message_printed("Importing taxonomies and filters for organization #{decidim_organization_id}")

      check_message_printed(<<~MSG)
        ...Importing 1 root taxonomies from decidim_participatory_process_types
          - Root taxonomy: ~ Participatory process types
            1st level taxonomies: 2
            Filters: 1
              - Filter name: ~ Participatory process types
                Internal name: -
                Manifest: participatory_processes
                Space filter: true
                Items: 2
                Components: 0
            !Taxonomy imported: Participatory Process Type 1
            !Taxonomy imported: Participatory Process Type 2
            !Filter imported: ~ Participatory process types
            Created taxonomies: 3
              - ~ Participatory process types
              - Participatory Process Type 1
              - Participatory Process Type 2
            Created filters: 1
              - participatory_processes: ~ Participatory process types: 2 items
            Assigned resources: 1
              - Participatory Process Type 1: 1 resources
            Assigned components: 0
            Failed resources: 0
            Failed components: 0
      MSG

      check_message_printed(<<~MSG)
        ...Importing 1 root taxonomies from decidim_assemblies_types
          - Root taxonomy: ~ Assemblies types
            1st level taxonomies: 2
            Filters: 1
              - Filter name: ~ Assemblies types
                Internal name: -
                Manifest: assemblies
                Space filter: true
                Items: 2
                Components: 0
            !Taxonomy imported: Assembly Type 1
            !Taxonomy imported: Assembly Type 2
            !Filter imported: ~ Assemblies types
            Created taxonomies: 3
              - ~ Assemblies types
              - Assembly Type 1
              - Assembly Type 2
            Created filters: 1
              - assemblies: ~ Assemblies types: 2 items
            Assigned resources: 1
              - Assembly Type 1: 1 resources
            Assigned components: 0
            Failed resources: 0
            Failed components: 0
      MSG

      check_message_printed(<<~MSG)
        ...Importing 1 root taxonomies from decidim_scopes
          - Root taxonomy: ~ Scopes
            1st level taxonomies: 2
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
            !Taxonomy imported: Scope 1
            !Taxonomy imported: Scope 2
            !Filter imported: ~ Scopes
            !Filter imported: ~ Scopes
            !Filter imported: ~ Scopes
            !Filter imported: ~ Scopes
            !Filter imported: ~ Scopes
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
            Assigned resources: 3
              - Scope 1: 1 resources
              - Scope 1 second level: 1 resources
              - Scope 2: 1 resources
            Assigned components: 1
              - assemblies: ~ Scopes: Dummy component: 1 components
            Failed resources: 0
            Failed components: 0
      MSG

      check_message_printed(<<~MSG)
        ...Importing 1 root taxonomies from decidim_areas
          - Root taxonomy: ~ Areas
            1st level taxonomies: 1
            Filters: 3
              - Filter name: ~ Areas
                Internal name: -
                Manifest: assemblies
                Space filter: true
                Items: 1
                Components: 0
              - Filter name: ~ Areas
                Internal name: -
                Manifest: participatory_processes
                Space filter: true
                Items: 1
                Components: 0
              - Filter name: ~ Areas
                Internal name: -
                Manifest: initiatives
                Space filter: true
                Items: 1
                Components: 0
            !Taxonomy imported: Area 1
            !Filter imported: ~ Areas
            !Filter imported: ~ Areas
            !Filter imported: ~ Areas
            Created taxonomies: 2
              - ~ Areas
              - Area 1
            Created filters: 3
              - assemblies: ~ Areas: 1 items
              - participatory_processes: ~ Areas: 1 items
              - initiatives: ~ Areas: 1 items
            Assigned resources: 1
              - Area 1: 1 resources
            Assigned components: 0
            Failed resources: 0
            Failed components: 0
      MSG

      check_message_printed(<<~MSG)
        ...Importing 1 root taxonomies from decidim_categories
          - Root taxonomy: ~ Categories
            1st level taxonomies: 2
            Filters: 1
              - Filter name: ~ Categories
                Internal name: Assembly: Assembly
                Manifest: assemblies
                Space filter: false
                Items: 2
                Components: 1
            !Taxonomy imported: Assembly: Assembly
            !Taxonomy imported: Participatory process: Process
            !Filter imported: ~ Categories
            Created taxonomies: 6
              - ~ Categories
              - Assembly: Assembly
              - Category 1
              - Sub Category 1
              - Participatory process: Process
              - Another Category 2
            Created filters: 1
              - assemblies: Assembly: Assembly: 2 items
            Assigned resources: 1
              - Category 1: 1 resources
            Assigned components: 1
              - assemblies: Assembly: Assembly: 1 components
            Failed resources: 0
            Failed components: 0
      MSG

      check_message_printed("Taxonomies and filters imported successfully.")

      expect(metric.reload.decidim_category_id).to eq(subcategory.id)
      expect(metric.decidim_taxonomy_id).to be_nil

      Rake::Task["decidim:taxonomies:update_all_metrics"].invoke
      check_message_printed("Updating 1 metrics for category #{subcategory.id} to taxonomy")
      expect(Decidim::Taxonomy.where(organization:).non_roots.pluck(:id)).to include(metric.reload.decidim_taxonomy_id)
    end
  end
end
