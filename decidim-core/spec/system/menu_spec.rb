# frozen_string_literal: true

require "spec_helper"

describe "Menu", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when clicking on a menu entry" do
    before do
      click_link("Help", match: :first)
    end

    it "switches the active option" do
      expect(page).to have_selector(".menu-bar__breadcrumb-desktop__dropdown-trigger", text: "Help")
    end

    context "and clicking on a subpage of that entry" do
      before do
        page = create(:static_page, organization:)

        visit current_path

        click_link page.title["en"]
      end

      it "preserves the active option" do
        expect(page).to have_selector(".menu-bar__breadcrumb-desktop__dropdown-trigger", text: "Help")
      end
    end
  end

  context "when rendering a component with special characters" do
    let(:component_name) { "Collaborative Drafts & Amendments" }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:proposal_component) { create(:proposal_component, name: { en: component_name }, participatory_space:) }
    let(:proposal) { create(:proposal, component: proposal_component) }
    let(:proposal_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

    before do
      visit proposal_path
    end

    it "renders the component name correctly" do
      expect(page).to have_selector(".menu-bar__breadcrumb-desktop__dropdown-wrapper", text: component_name)
    end
  end
end
