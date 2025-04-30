# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

describe "Executing Decidim Taxonomy importer tasks" do
  let(:plan_file) { Rails.root.join("tmp/taxonomies/#{organization.host}_plan.json") }
  let(:another_plan_file) { Rails.root.join("tmp/taxonomies/#{external_organization.host}_plan.json") }

  let!(:organization) { create(:organization, host: "foo.example.org") }
  let!(:external_organization) { create(:organization, host: "bar.example.org") }

  let!(:external_scope) { Decidim::Maintenance::ImportModels::Scope.create!(name: { "en" => "External Scope 1" }, code: "3", decidim_organization_id: external_organization.id) }
  let!(:external_sub_scope) { Decidim::Maintenance::ImportModels::Scope.create!(name: { "en" => "External Scope 1 second level" }, code: "31", decidim_organization_id: external_organization.id, parent: external_scope) }
  let!(:external_participatory_process) { create(:participatory_process, title: { "en" => "External Process" }, organization: external_organization, decidim_scope_id: external_scope.id) }
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
  # category_nil is here to avoid triggering the category creation in the factory
  let(:settings) { { scopes_enabled: true, scope_id: sub_scope.id } }

  before do
    allow($stdout).to receive(:puts).and_call_original

    scope.update!(part_of: [scope.id])
    another_scope.update!(part_of: [scope.id])
    sub_scope.update!(part_of: [scope.id, sub_scope.id])
    # as scope settings are disabled now, we need to update the settings directly as it was already there
    # rubocop:disable Rails/SkipsModelValidations
    dummy_component.update_column(:settings, {
                                    "global" => settings
                                  })
    # rubocop:enable Rails/SkipsModelValidations

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
      expect(process_type_roots["~ Participatory process types"]["filters"].first["participatory_space_manifests"]).to eq(["participatory_processes"])
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
      expect(assembly_types_roots["~ Assemblies types"]["filters"].first["participatory_space_manifests"]).to eq(["assemblies"])
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

      expect(scope_roots["~ Scopes"]["filters"].count).to eq(2)
      expect(scope_roots["~ Scopes"]["filters"]).to include(
        "participatory_space_manifests" => %w(assemblies participatory_processes conferences initiatives),
        "name" => "~ Scopes",
        "items" => [["Scope 1"], ["Scope 1", "Scope 1 second level"], ["Scope 2"]],
        "components" => []
      )

      expect(scope_roots["~ Scopes"]["filters"]).to include(
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
      expect(areas_roots["~ Areas"]["filters"].count).to eq(1)
      expect(areas_roots["~ Areas"]["filters"]).to include(
        "participatory_space_manifests" => %w(assemblies participatory_processes initiatives),
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
        "internal_name" => "Assembly: Assembly",
        "name" => "~ Categories",
        "items" => [["Assembly: Assembly", "Category 1"],
                    ["Assembly: Assembly", "Category 1", "Sub Category 1"]],
        "components" => [
          dummy_component.to_global_id.to_s
        ]
      )

      expect($stdout.string).to include("Creating a plan for organization #{decidim_organization_id}")
      expect($stdout.string).to include("...Exporting taxonomies for decidim_participatory_process_types")
      expect($stdout.string).to include("...Exporting taxonomies for decidim_assemblies_types")
      expect($stdout.string).to include("...Exporting taxonomies for decidim_scopes")
      expect($stdout.string).to include("...Exporting taxonomies for decidim_areas")
      expect($stdout.string).to include("...Exporting taxonomies for decidim_categories")
      expect($stdout.string).to include("Plan created")
    end

    context "when the IMPORT env var is set" do
      before do
        allow(ENV).to receive(:fetch).with("IMPORTS", "ParticipatoryProcessType AssemblyType Scope Area Category").and_return("Scope Area")
      end

      it "creates a plan and imports it" do
        task.reenable
        task.invoke

        expect($stdout.string).to include("Creating a plan for organization #{decidim_organization_id}")
        expect($stdout.string).not_to include("...Exporting taxonomies for decidim_participatory_process_types")
        expect($stdout.string).not_to include("...Exporting taxonomies for decidim_assemblies_types")
        expect($stdout.string).to include("...Exporting taxonomies for decidim_scopes")
        expect($stdout.string).to include("...Exporting taxonomies for decidim_areas")
        expect($stdout.string).not_to include("...Exporting taxonomies for decidim_categories")
        expect($stdout.string).to include("Plan created")
      end
    end
  end

  describe "rake decidim:taxonomies:import_all_plans", type: :task do
    let!(:organization) { create(:organization, host: "baz.example.org") }
    let!(:external_organization) { create(:organization, host: "qux.example.org") }

    let(:task) { Rake::Task["decidim:taxonomies:import_all_plans"] }

    before do
      FileUtils.rm_f(Rails.root.join("tmp/taxonomies/bar.example.org_plan.json"))
      FileUtils.rm_f(Rails.root.join("tmp/taxonomies/foo.example.org_plan.json"))
      sleep(0.1) # Filesystem may need some time to update
      Rake::Task["decidim:taxonomies:make_plan"].reenable
      Rake::Task["decidim:taxonomies:make_plan"].invoke
    end

    it "imports the plan for all organizations" do # rubocop:disable RSpec/ExampleLength
      expect { task.invoke }.to change(Decidim::Taxonomy, :count).by(21)

      expect($stdout.string).to include("Importing plan from #{plan_file}")
      expect($stdout.string).to include("Importing plan from #{another_plan_file}")
      expect($stdout.string).to include("Importing taxonomies and filters for organization #{decidim_organization_id}")
      expect($stdout.string).to include("Importing taxonomies and filters for organization #{external_organization.id}")

      expect($stdout.string).to include(<<~MSG)
        ...Importing 1 root taxonomies from decidim_participatory_process_types
          - Root taxonomy: ~ Participatory process types
            1st level taxonomies: 2
            Filters: 1
              - Filter name: ~ Participatory process types
                Internal name: -
                Space manifests: participatory_processes
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
              - ~ Participatory process types: 2 items
            Assigned resources: 1
              - Participatory Process Type 1: 1 resources
            Assigned components: 0
            Failed resources: 0
            Failed components: 0
      MSG

      expect($stdout.string).to include(<<~MSG)
        ...Importing 1 root taxonomies from decidim_assemblies_types
          - Root taxonomy: ~ Assemblies types
            1st level taxonomies: 2
            Filters: 1
              - Filter name: ~ Assemblies types
                Internal name: -
                Space manifests: assemblies
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
              - ~ Assemblies types: 2 items
            Assigned resources: 1
              - Assembly Type 1: 1 resources
            Assigned components: 0
            Failed resources: 0
            Failed components: 0
      MSG

      expect($stdout.string).to include(<<~MSG)
        ...Importing 1 root taxonomies from decidim_scopes
          - Root taxonomy: ~ Scopes
            1st level taxonomies: 2
            Filters: 2
              - Filter name: ~ Scopes
                Internal name: ~ Scopes: Dummy component
                Space manifests: -
                Items: 1
                Components: 1
              - Filter name: ~ Scopes
                Internal name: -
                Space manifests: assemblies, participatory_processes, conferences, initiatives
                Items: 3
                Components: 0
            !Taxonomy imported: Scope 1
            !Taxonomy imported: Scope 2
            !Filter imported: ~ Scopes
            !Filter imported: ~ Scopes
            Created taxonomies: 4
              - ~ Scopes
              - Scope 1
              - Scope 1 second level
              - Scope 2
            Created filters: 2
              - ~ Scopes: Dummy component: 1 items
              - ~ Scopes: 3 items
            Assigned resources: 3
              - Scope 1: 1 resources
              - Scope 1 second level: 1 resources
              - Scope 2: 1 resources
            Assigned components: 1
              - ~ Scopes: Dummy component: 1 components
            Failed resources: 0
            Failed components: 0
      MSG

      expect($stdout.string).to include(<<~MSG)
        ...Importing 1 root taxonomies from decidim_areas
          - Root taxonomy: ~ Areas
            1st level taxonomies: 1
            Filters: 1
              - Filter name: ~ Areas
                Internal name: -
                Space manifests: assemblies, participatory_processes, initiatives
                Items: 1
                Components: 0
            !Taxonomy imported: Area 1
            !Filter imported: ~ Areas
            Created taxonomies: 2
              - ~ Areas
              - Area 1
            Created filters: 1
              - ~ Areas: 1 items
            Assigned resources: 1
              - Area 1: 1 resources
            Assigned components: 0
            Failed resources: 0
            Failed components: 0
      MSG

      expect($stdout.string).to include(<<~MSG)
        ...Importing 1 root taxonomies from decidim_categories
          - Root taxonomy: ~ Categories
            1st level taxonomies: 2
            Filters: 1
              - Filter name: ~ Categories
                Internal name: Assembly: Assembly
                Space manifests: -
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
              - Assembly: Assembly: 2 items
            Assigned resources: 1
              - Category 1: 1 resources
            Assigned components: 1
              - Assembly: Assembly: 1 components
            Failed resources: 0
            Failed components: 0
      MSG

      expect($stdout.string).to include("Taxonomies and filters imported successfully.")
    end
  end
end
