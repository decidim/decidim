# frozen_string_literal: true

shared_examples "import proposals" do
  let!(:proposals) { create_list :proposal, 3, :accepted, component: origin_component }
  let!(:rejected_proposals) { create_list :proposal, 3, :rejected, component: origin_component }
  let!(:origin_component) { create :proposal_component, participatory_space: current_component.participatory_space }
  include Decidim::ComponentPathHelper

  it "imports proposals from one component to another" do
    fill_form

    confirm_flash_message

    proposals.each do |proposal|
      expect(page).to have_content(proposal.title["en"])
    end

    confirm_current_path
  end

  it "imports proposals from one component to another by keeping the authors" do
    fill_form(keep_authors: true)

    confirm_flash_message

    proposals.each do |proposal|
      expect(page).to have_content(proposal.title["en"])
    end

    confirm_current_path
  end

  def fill_form(keep_authors: false)
    click_link "Import from another component"

    within ".import_proposals" do
      select origin_component.name["en"], from: "Origin component"
      check "Accepted"
      check "Keep original authors" if keep_authors
      check "Import proposals"
    end

    click_button "Import proposals"
  end

  def confirm_flash_message
    expect(page).to have_content("3 proposals successfully imported")
  end

  def confirm_current_path
    expect(page).to have_current_path(manage_component_path(current_component))
  end
end
