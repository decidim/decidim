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
      visit decidim.pages_path(locale: I18n.locale)
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
        expect(page).to have_link("Processes", href: "/#{I18n.locale}/processes")
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

  describe "when there are special characters (', &) in the nav links" do
    let(:component_name) { "People's Budget & Ideas" }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:proposal_component) { create(:proposal_component, name: { en: component_name }, participatory_space:) }
    let(:proposal) { create(:proposal, component: proposal_component) }
    let(:proposal_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

    context "when it is a desktop device" do
      it "renders the component name correctly" do
        visit proposal_path
        within ".menu-bar__breadcrumb-desktop" do
          expect(page).to have_text(component_name)
          expect(page).to have_no_text("&#39;")
          expect(page).to have_no_text("&amp;#39;")
        end
      end
    end

    context "when it is a mobile device" do
      before do
        driven_by(:iphone)
      end

      it "renders the component name correctly" do
        visit proposal_path
        within ".menu-bar__breadcrumb-mobile" do
          expect(page).to have_text(component_name)
          expect(page).to have_no_text("&#39;")
          expect(page).to have_no_text("&amp;#39;")
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
      expect(page).to have_text("Statistics")
      expect(page).to have_css(".statistic__dashboard-container")
    end
  end
end
