# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

describe "Executing Decidim Taxonomy importer tasks" do
  let(:plan_file) { Rails.root.join("tmp/taxonomies/#{organization.host}_plan.json") }
  let(:organization) { create(:organization) }
  let(:decidim_organization_id) { organization.id }
  let!(:participatory_process) { create(:participatory_process, organization:) }

  # avoid using factories for this test in case old models are removed
  before do
    type1 = Decidim::Maintenance::ParticipatoryProcessType.create!(title: { "en" => "Participatory Process Type 1", "ca" => "Tipus de procés participatiu 1" }, decidim_organization_id:)
    Decidim::Maintenance::ParticipatoryProcessType.create!(title: { "en" => "Participatory Process Type 2", "ca" => "Tipus de procés participatiu 2" }, decidim_organization_id:)
    participatory_process.update(decidim_participatory_process_type_id: type1.id)
  end

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

      roots = json_content["imported_taxonomies"]["decidim_participatory_process_types"]
      expect(roots.count).to eq(1)
      expect(roots.keys.first).to eq("Participatory process types")
      taxonomies = roots["Participatory process types"]["taxonomies"]
      expect(taxonomies.count).to eq(2)
      expect(taxonomies.keys).to contain_exactly("Participatory Process Type 1", "Participatory Process Type 2")
      expect(taxonomies["Participatory Process Type 1"]["name"]).to eq({ "en" => "Participatory Process Type 1", "ca" => "Tipus de procés participatiu 1" })
      expect(taxonomies["Participatory Process Type 1"]["resources"]).to eq({
                                                                              participatory_process.to_global_id.to_s => participatory_process.title[organization.default_locale]
                                                                            })
      expect(taxonomies["Participatory Process Type 2"]["resources"]).to eq({})
      expect(taxonomies["Participatory Process Type 2"]["name"]).to eq({ "en" => "Participatory Process Type 2", "ca" => "Tipus de procés participatiu 2" })

      check_message_printed("Creating a plan for organization #{decidim_organization_id}")
      check_message_printed("...Exporting taxonomies for decidim_participatory_process_types")
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
      expect { task.invoke }.to change(Decidim::Taxonomy, :count).by(3)

      check_message_printed("Importing taxonomies and filters for organization #{decidim_organization_id}")
      check_message_printed("...Importing 1 taxonomies from decidim_participatory_process_types")
      check_message_printed("  - Root taxonomy: Participatory process types")
      check_message_printed("    Taxonomy items: 2")
      check_message_printed("    Filters: 1")
      check_message_printed("     - Filter name: Participatory process types")
      check_message_printed("       Manifest: participatory_processes")
      check_message_printed("       Space filter: true")
      check_message_printed("       Items: 2")
      check_message_printed("       Components: 0")
      check_message_printed("    Created taxonomies: 3")
      check_message_printed("      - Participatory process types")
      check_message_printed("      - Participatory Process Type 1")
      check_message_printed("      - Participatory Process Type 2")
    end
  end
end
