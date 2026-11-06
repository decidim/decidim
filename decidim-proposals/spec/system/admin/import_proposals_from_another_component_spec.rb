# frozen_string_literal: true

require "spec_helper"

describe "Import proposals from another component" do
  let(:component) { create(:proposal_component) }
  let(:participatory_space) { component.participatory_space }
  let!(:origin_component) { create(:proposal_component, participatory_space:) }
  let(:organization) { component.organization }

  let(:manifest_name) { "proposals" }
  let(:user) { create(:user, organization:) }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:proposal_component, participatory_space:) }
  end

  before do
    click_on "Import"
    click_on "Import proposals from another component"
  end

  it "does not show status checkboxes before a component is selected" do
    expect(page).to have_no_css("#statuses-container input[type='checkbox']")
  end

  it "dynamically loads status checkboxes after selecting an origin component" do
    within ".import_proposals" do
      select origin_component.name["en"], from: "Origin component"
    end

    within "#statuses-container" do
      expect(page).to have_unchecked_field("Accepted")
      expect(page).to have_unchecked_field("Rejected")
      expect(page).to have_unchecked_field("Evaluating")
      expect(page).to have_unchecked_field("Not answered")
    end
  end

  it "hides status checkboxes when the component selection is cleared" do
    within ".import_proposals" do
      select origin_component.name["en"], from: "Origin component"
    end

    expect(page).to have_css("#statuses-container input[type='checkbox']")

    within ".import_proposals" do
      select "Please select a component", from: "Origin component"
    end

    expect(page).to have_no_css("#statuses-container input[type='checkbox']")
  end

  context "when importing proposals filtered by status" do
    let!(:accepted_proposals) { create_list(:proposal, 2, :accepted, component: origin_component) }
    let!(:rejected_proposals) { create_list(:proposal, 1, :rejected, component: origin_component) }

    it "only imports proposals matching the selected status" do
      within ".import_proposals" do
        select origin_component.name["en"], from: "Origin component"
        check "Accepted"
      end

      click_on "Import proposals"

      expect(page).to have_text("The import process has started. We will let you know once it has finished.")
      perform_enqueued_jobs
      visit current_path

      expect(Decidim::Proposals::Proposal.where(component:).count).to eq(2)
    end
  end

  context "with a custom status on the origin component" do
    let(:custom_title) { { "en" => "Under review" } }
    let!(:custom_status) do
      create(:proposal_status, component: origin_component, token: "under_review", title: custom_title)
    end

    it "shows the custom status alongside the default ones" do
      within ".import_proposals" do
        select origin_component.name["en"], from: "Origin component"
      end

      within "#statuses-container" do
        expect(page).to have_unchecked_field("Under review")
        expect(page).to have_unchecked_field("Accepted")
        expect(page).to have_unchecked_field("Not answered")
      end
    end

    context "when importing proposals with the custom status" do
      let!(:custom_status_on_target) do
        create(:proposal_status, component:, token: "under_review", title: custom_title)
      end
      let!(:custom_proposals) { create_list(:proposal, 2, component: origin_component, status: "under_review") }
      let!(:accepted_proposals) { create_list(:proposal, 1, :accepted, component: origin_component) }

      it "only imports proposals in the custom status" do
        within ".import_proposals" do
          select origin_component.name["en"], from: "Origin component"
          check "Under review"
        end

        click_on "Import proposals"

        expect(page).to have_text("The import process has started. We will let you know once it has finished.")
        perform_enqueued_jobs
        visit current_path

        expect(Decidim::Proposals::Proposal.where(component:).count).to eq(2)
      end
    end

    context "when no statuses are selected" do
      let!(:proposals) { create_list(:proposal, 3, component: origin_component) }

      it "imports all proposals" do
        within ".import_proposals" do
          select origin_component.name["en"], from: "Origin component"
        end

        click_on "Import proposals"

        expect(page).to have_text("The import process has started. We will let you know once it has finished.")
        perform_enqueued_jobs
        visit current_path

        expect(Decidim::Proposals::Proposal.where(component:).count).to eq(3)
      end
    end
  end
end
