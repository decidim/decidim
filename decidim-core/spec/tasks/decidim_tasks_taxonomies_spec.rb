# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

describe "Executing Decidim Taxonomy importer tasks" do
  let(:plan_file) { Rails.root.join("tmp/taxonomies/#{organization.host}_plan.json") }
  let(:organization) { create(:organization) }
  let(:decidim_organization_id) { organization.id }

  # avoid using factories for this test in case old models are removed
  let!(:process_type1) { Decidim::Maintenance::ParticipatoryProcessType.create!(title: { "en" => "Participatory Process Type 1", "ca" => "Tipus de procés participatiu 1" }, decidim_organization_id: organization.id) }
  let!(:process_type2) { Decidim::Maintenance::ParticipatoryProcessType.create!(title: { "en" => "Participatory Process Type 2", "ca" => "Tipus de procés participatiu 2" }, decidim_organization_id: organization.id) }
  let!(:participatory_process) { create(:participatory_process, organization:, decidim_participatory_process_type_id: process_type1.id) }
  let!(:assembly_type1) { Decidim::Maintenance::AssemblyType.create!(title: { "en" => "Assembly Type 1", "ca" => "Tipus d'assemblea 1" }, decidim_organization_id: organization.id) }
  let!(:assembly_type2) { Decidim::Maintenance::AssemblyType.create!(title: { "en" => "Assembly Type 2", "ca" => "Tipus d'assemblea 2" }, decidim_organization_id: organization.id) }
  let!(:assembly) { create(:assembly, organization:, decidim_assemblies_type_id: assembly_type1.id) }

  describe "rake decidim:taxonomies:make_plan", type: :task do
    let(:task) { Rake::Task["decidim:taxonomies:make_plan"] }

    it "creates a plan with the current categories, scopes and types" do
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
      expect(process_type_roots.keys.first).to eq("Participatory process types")
      taxonomies = process_type_roots["Participatory process types"]["taxonomies"]
      expect(taxonomies.count).to eq(2)
      expect(taxonomies.keys).to contain_exactly("Participatory Process Type 1", "Participatory Process Type 2")
      expect(taxonomies["Participatory Process Type 1"]["name"]).to eq({ "en" => "Participatory Process Type 1", "ca" => "Tipus de procés participatiu 1" })
      expect(taxonomies["Participatory Process Type 1"]["resources"]).to eq({
                                                                              participatory_process.to_global_id.to_s => participatory_process.title[organization.default_locale]
                                                                            })
      expect(taxonomies["Participatory Process Type 2"]["resources"]).to eq({})
      expect(taxonomies["Participatory Process Type 2"]["name"]).to eq({ "en" => "Participatory Process Type 2", "ca" => "Tipus de procés participatiu 2" })

      expect(process_type_roots["Participatory process types"]["filters"].count).to eq(1)
      expect(process_type_roots["Participatory process types"]["filters"].keys.first).to eq("Participatory process types")
      expect(process_type_roots["Participatory process types"]["filters"]["Participatory process types"]["space_filter"]).to be(true)
      expect(process_type_roots["Participatory process types"]["filters"]["Participatory process types"]["space_manifest"]).to eq("participatory_processes")
      expect(process_type_roots["Participatory process types"]["filters"]["Participatory process types"]["items"]).to contain_exactly(["Participatory Process Type 1"], ["Participatory Process Type 2"])
      expect(process_type_roots["Participatory process types"]["filters"]["Participatory process types"]["components"]).to eq([])

      assembly_types_roots = json_content["imported_taxonomies"]["decidim_assemblies_types"]
      expect(assembly_types_roots.count).to eq(1)
      expect(assembly_types_roots.keys.first).to eq("Assemblies types")
      taxonomies = assembly_types_roots["Assemblies types"]["taxonomies"]
      expect(taxonomies.count).to eq(2)
      expect(taxonomies.keys).to contain_exactly("Assembly Type 1", "Assembly Type 2")
      expect(taxonomies["Assembly Type 1"]["name"]).to eq({ "en" => "Assembly Type 1", "ca" => "Tipus d'assemblea 1" })
      expect(taxonomies["Assembly Type 1"]["resources"]).to eq({ assembly.to_global_id.to_s => assembly.title[organization.default_locale] })
      expect(taxonomies["Assembly Type 2"]["resources"]).to eq({})
      expect(taxonomies["Assembly Type 2"]["name"]).to eq({ "en" => "Assembly Type 2", "ca" => "Tipus d'assemblea 2" })

      expect(assembly_types_roots["Assemblies types"]["filters"].count).to eq(1)
      expect(assembly_types_roots["Assemblies types"]["filters"].keys.first).to eq("Assemblies types")
      expect(assembly_types_roots["Assemblies types"]["filters"]["Assemblies types"]["space_filter"]).to be(true)
      expect(assembly_types_roots["Assemblies types"]["filters"]["Assemblies types"]["space_manifest"]).to eq("assemblies")
      expect(assembly_types_roots["Assemblies types"]["filters"]["Assemblies types"]["items"]).to contain_exactly(["Assembly Type 1"], ["Assembly Type 2"])
      expect(assembly_types_roots["Assemblies types"]["filters"]["Assemblies types"]["components"]).to eq([])

      check_message_printed("Creating a plan for organization #{decidim_organization_id}")
      check_message_printed("...Exporting taxonomies for decidim_participatory_process_types")
      check_message_printed("...Exporting taxonomies for decidim_assemblies_types")
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

    it "imports the plan for all organizations" do
      expect { task.invoke }.to change(Decidim::Taxonomy, :count).by(6)

      check_message_printed("Importing taxonomies and filters for organization #{decidim_organization_id}")
      check_message_printed(<<~MSG)
        ...Importing 1 taxonomies from decidim_participatory_process_types
          - Root taxonomy: Participatory process types
            Taxonomy items: 2
            Filters: 1
              - Filter name: Participatory process types
                Manifest: participatory_processes
                Space filter: true
                Items: 2
                Components: 0
            Created taxonomies: 3
              - Participatory process types
              - Participatory Process Type 1
              - Participatory Process Type 2
            Created filters: 1
              - Participatory process types:
                - Participatory Process Type 1
                - Participatory Process Type 2
            Assigned resources: 1
              - Participatory Process Type 1:
                - #{participatory_process.to_global_id}
            Failed resources: 0
            Failed components: 0
        ...Importing 1 taxonomies from decidim_assemblies_types
          - Root taxonomy: Assemblies types
            Taxonomy items: 2
            Filters: 1
              - Filter name: Assemblies types
                Manifest: assemblies
                Space filter: true
                Items: 2
                Components: 0
            Created taxonomies: 3
              - Assemblies types
              - Assembly Type 1
              - Assembly Type 2
            Created filters: 1
              - Assemblies types:
                - Assembly Type 1
                - Assembly Type 2
            Assigned resources: 1
              - Assembly Type 1:
                - #{assembly.to_global_id}
            Failed resources: 0
            Failed components: 0
        Taxonomies and filters imported successfully.
      MSG
    end
  end
end
