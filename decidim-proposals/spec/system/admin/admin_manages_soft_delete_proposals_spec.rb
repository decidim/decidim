# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposal soft delete" do
  include_context "when managing a component as an admin"

  let(:manifest_name) { "proposals" }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { current_path }
  let(:trash_path) { "#{admin_resource_path}/proposals/manage_trash" }
  let(:title) { { en: "My proposal" } }
  let!(:resource) { create(:proposal, component: current_component, title:) }

  it_behaves_like "manage soft deletable resource", "proposal"
  it_behaves_like "manage trashed resource", "proposal"

  describe "restoring a soft-deleted proposal" do
    let(:author) { resource.creator_author }
    let!(:likes) do
      2.times.collect do
        create(:like, resource:, author: create(:user, :confirmed, organization:))
      end
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      resource.destroy!
      visit trash_path

      within("tr", text: title[:en]) do
        find("button[data-controller='dropdown']").click
        click_on "Restore"
      end

      expect(page).to have_callout("Proposal successfully restored.")
      visit admin_resource_path

      within "tr", text: title[:en] do
        find("button[data-controller='dropdown']").click
        click_on "Answer proposal"
      end
    end

    it "shows the author name after restoring" do
      within ".component__show_nav-author" do
        expect(page).to have_text(author.name)
      end
    end

    it "shows the likes count after restoring" do
      expect(page).to have_css("[data-likes] [data-count]", text: "2")
    end
  end
end
