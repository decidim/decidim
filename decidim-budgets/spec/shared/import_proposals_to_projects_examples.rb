# frozen_string_literal: true

shared_examples "import proposals to projects" do
  let!(:proposals) { create_list(:proposal, 3, :accepted, component: origin_component) }
  let!(:rejected_proposals) { create_list(:proposal, 3, :rejected, component: origin_component) }
  let!(:origin_component) { create(:proposal_component, participatory_space: current_component.participatory_space) }
  let!(:default_budget) { 2333 }
  include Decidim::ComponentPathHelper

  it "imports proposals from one component to a budget component" do
    find("a", text: "Import").click
    click_on "Import proposals to projects"

    within ".import_proposals" do
      select origin_component.name["en"], from: :proposals_import_origin_component_id
      fill_in "Default budget", with: default_budget
      check :proposals_import_import_all_accepted_proposals
    end

    click_on "Import proposals to projects"

    expect(page).to have_content("3 proposals successfully imported")

    proposals.each do |project|
      expect(page).to have_content(project.title["en"])
    end
  end
end
