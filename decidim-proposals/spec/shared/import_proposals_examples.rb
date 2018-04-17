# frozen_string_literal: true

shared_examples "import proposals" do
  let!(:proposals) { create_list :proposal, 3, :accepted, component: origin_component }
  let!(:rejected_proposals) { create_list :proposal, 3, :rejected, component: origin_component }
  let!(:origin_component) { create :proposal_component, participatory_space: current_component.participatory_space }
  include Decidim::ComponentPathHelper

  it "imports proposals from one component to another" do
    click_link "Import from another component"

    within ".import_proposals" do
      select origin_component.name["en"], from: :proposals_import_origin_component_id
      check "Accepted"
      check :proposals_import_import_proposals
    end

    click_button "Import proposals"

    expect(page).to have_content("3 proposals successfully imported")

    proposals.each do |proposal|
      expect(page).to have_content(proposal.title["en"])
    end

    expect(page).to have_current_path(manage_component_path(current_component))
  end
end
