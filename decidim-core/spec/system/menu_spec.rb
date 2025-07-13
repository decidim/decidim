# frozen_string_literal: true

require "spec_helper"

describe "Menu" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when clicking on a menu entry" do
    before do
      click_on("Help", match: :first)
    end

    it "switches the active option" do
      expect(page).to have_css(".menu-bar__breadcrumb-desktop__dropdown-trigger", text: "Home")
    end

    context "and clicking on a subpage of that entry" do
      before do
        page = create(:static_page, organization:)

        visit current_path

        click_on page.title["en"]
      end

      it "preserves the active option" do
        expect(page).to have_css(".menu-bar__breadcrumb-desktop__dropdown-trigger", text: "Home")
      end
    end
  end

  context "when the device is mobile" do
    let!(:participatory_space) { create(:participatory_process, organization:) }

    before do
      driven_by(:iphone)
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "shows the mobile menu" do
      click_on(id: "main-dropdown-summary-mobile")

      within "#breadcrumb-main-dropdown-mobile" do
        expect(page).to have_link("Home", href: "/")
        expect(page).to have_link("Processes", href: "/processes")
        expect(page).to have_link("Help", href: "/pages")
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
      expect(page).to have_css(".menu-bar__breadcrumb-desktop__dropdown-wrapper", text: component_name)
    end
  end

  describe "header message in desktop" do
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:component) { create(:proposal_component, participatory_space:) }
    let(:proposal) { create(:proposal, component:) }
    let(:proposal_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

    before do
      visit proposal_path
      find_by_id("main-dropdown-summary").hover
    end

    context "when the organization does not have a description" do
      let(:organization) { create(:organization, description: { en: nil }) }

      it "shows the default message" do
        within "#breadcrumb-main-dropdown-desktop" do
          expect(page).to have_text("Let's build a more open, transparent and collaborative society.")
        end
      end
    end

    context "when the organization has a description" do
      it "shows the organization description" do
        within "#breadcrumb-main-dropdown-desktop" do
          expect(page).to have_no_text("Let's build a more open, transparent and collaborative society.")
          expect(page).to have_text(strip_tags(translated(organization.description)))
        end
      end
    end
  end

  context "when the admin_insights_menu is displayed" do
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim.root_path
      click_on "Admin dashboard"
      click_on "Insights"
      click_on "Statistics"
    end

    it "includes the statistics item" do
      expect(page).to have_content("Statistics")
      expect(page).to have_css(".statistic__dashboard-container")
    end
  end
end
