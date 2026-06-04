# frozen_string_literal: true

require "spec_helper"

describe "Import proposals to projects" do
  let(:manifest_name) { "budgets" }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:budget) { create(:budget, component: current_component) }
  let!(:origin_component) { create(:proposal_component, participatory_space:) }
  let(:organization) { current_component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit_component_admin

    within "tr", text: translated(budget.title) do
      find("button[data-controller='dropdown']").click
      click_on "Add projects"
    end

    click_on "Import"
    click_on "Import proposals to projects"
  end

  it "does not show state checkboxes before a component is selected" do
    expect(page).to have_no_css("#states-container input[type='checkbox']")
  end

  it "dynamically loads state checkboxes after selecting an origin component" do
    within ".import_proposals" do
      select origin_component.name["en"], from: "Origin component"
    end

    within "#states-container" do
      expect(page).to have_unchecked_field("Accepted")
      expect(page).to have_unchecked_field("Rejected")
      expect(page).to have_unchecked_field("Evaluating")
      expect(page).to have_unchecked_field("Not answered")
    end
  end

  it "hides state checkboxes when the component selection is cleared" do
    within ".import_proposals" do
      select origin_component.name["en"], from: "Origin component"
    end

    expect(page).to have_css("#states-container input[type='checkbox']")

    within ".import_proposals" do
      select "Please select a component", from: "Origin component"
    end

    expect(page).to have_no_css("#states-container input[type='checkbox']")
  end

  context "when importing proposals filtered by state" do
    let!(:accepted_proposals) { create_list(:proposal, 2, :accepted, component: origin_component) }
    let!(:rejected_proposals) { create_list(:proposal, 1, :rejected, component: origin_component) }

    it "only imports proposals matching the selected state" do
      within ".import_proposals" do
        select origin_component.name["en"], from: "Origin component"
        fill_in "Default budget", with: 1000
        check "Accepted"
      end

      click_on "Import proposals to projects"

      expect(page).to have_text("2 proposals successfully imported")
      expect(Decidim::Budgets::Project.where(budget:).count).to eq(2)
    end
  end

  context "with a custom state on the origin component" do
    let(:custom_title) { { "en" => "Under review" } }
    let!(:custom_state) do
      create(:proposal_state, component: origin_component, token: "under_review", title: custom_title)
    end

    it "shows the custom state alongside the default ones" do
      within ".import_proposals" do
        select origin_component.name["en"], from: "Origin component"
      end

      within "#states-container" do
        expect(page).to have_unchecked_field("Under review")
        expect(page).to have_unchecked_field("Accepted")
        expect(page).to have_unchecked_field("Not answered")
      end
    end

    context "when importing proposals with the custom state" do
      let!(:custom_proposals) do
        create_list(:proposal, 2, :published, component: origin_component).each do |proposal|
          proposal.update!(proposal_state: custom_state)
        end
      end
      let!(:accepted_proposals) { create_list(:proposal, 1, :accepted, component: origin_component) }

      it "only imports proposals in the custom state" do
        within ".import_proposals" do
          select origin_component.name["en"], from: "Origin component"
          fill_in "Default budget", with: 1000
          check "Under review"
        end

        click_on "Import proposals to projects"

        expect(page).to have_text("2 proposals successfully imported")
        expect(Decidim::Budgets::Project.where(budget:).count).to eq(2)
      end
    end

    context "when no states are selected" do
      let!(:proposals) { create_list(:proposal, 3, :published, component: origin_component) }

      it "imports all proposals" do
        within ".import_proposals" do
          select origin_component.name["en"], from: "Origin component"
          fill_in "Default budget", with: 1000
        end

        click_on "Import proposals to projects"

        expect(page).to have_text("3 proposals successfully imported")
        expect(Decidim::Budgets::Project.where(budget:).count).to eq(3)
      end
    end
  end
end
