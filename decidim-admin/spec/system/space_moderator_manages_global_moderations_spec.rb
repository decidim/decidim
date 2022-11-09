# frozen_string_literal: true

require "spec_helper"

describe "Space moderator manages global moderations", type: :system do
  let!(:user) do
    create(
      :process_moderator,
      :confirmed,
      organization: organization,
      admin_terms_accepted_at: Time.current,
      participatory_process: participatory_space
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create :component }
  let(:participatory_space) { current_component.participatory_space }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.root_path
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the user hasn't accepted the Terms of Use" do
    before do
      user.update(admin_terms_accepted_at: nil)
    end

    it "doesn't have the menu item in the main navigation" do
      visit participatory_space_path

      within ".main-nav" do
        expect(page).not_to have_text("Global moderations")
      end
    end

    it "can't access to the Global moderations page" do
      visit decidim_admin.moderations_path

      within ".callout.alert" do
        expect(page).to have_text("You are not authorized to perform this action")
      end
    end
  end

  context "when the user can manage a space that has moderations" do
    it_behaves_like "manage moderations" do
      let(:moderations_link_text) { "Global moderations" }
    end
  end

  context "when the user can manage a space without moderations" do
    let(:participatory_space) do
      create :participatory_process, organization: organization
    end

    it "can't see any moderation" do
      visit decidim_admin.moderations_path

      within ".container" do
        expect(page).to have_content("Moderations")

        expect(page).to have_no_selector("table.table-list tbody tr")
      end
    end
  end
end
