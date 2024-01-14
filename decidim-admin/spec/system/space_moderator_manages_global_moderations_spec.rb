# frozen_string_literal: true

require "spec_helper"

describe "Space moderator manages global moderations" do
  let!(:user) do
    create(
      :process_moderator,
      :confirmed,
      organization:,
      admin_terms_accepted_at: Time.current,
      participatory_process: participatory_space
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create(:component) }
  let(:participatory_space) { current_component.participatory_space }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.root_path
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the user has not accepted the Terms of Service" do
    before do
      user.update(admin_terms_accepted_at: nil)
    end

    it "does not have the menu item in the main navigation" do
      visit participatory_space_path
      within ".main-nav + .main-nav" do
        expect(page).not_to have_text("Global moderations")
      end
    end

    it "cannot access to the Global moderations page" do
      visit decidim_admin.moderations_path

      expect(page).to have_content("Please take a moment to review the admin terms of service")
    end
  end

  context "when the user can manage a space that has moderations" do
    it_behaves_like "manage moderations" do
      let(:moderations_link_text) { "Global moderations" }
      let(:moderations_link_in_admin_menu) { false }
    end

    it_behaves_like "sorted moderations" do
      let!(:reportables) { create_list(:dummy_resource, 17, component: current_component) }
      let(:moderations_link_text) { "Global moderations" }
      let(:moderations_link_in_admin_menu) { false }
    end
  end

  context "when the user can manage a space without moderations" do
    let(:participatory_space) do
      create(:participatory_process, organization:)
    end

    it "cannot see any moderation" do
      visit decidim_admin.moderations_path

      within "[data-content]" do
        expect(page).to have_content("Reported content")

        expect(page).not_to have_selector("table.table-list tbody tr")
      end
    end
  end
end
