# frozen_string_literal: true

require "spec_helper"

describe "Admin manages the monitoring committee", type: :system do
  include_context "when admin managing a voting"

  let(:other_user) { create :user, organization:, email: "my_email@example.org" }
  let!(:monitoring_committee_member) { create :monitoring_committee_member, user: other_user, voting: }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
    click_link "Members"
  end

  it "shows all members in the monitoring committee page" do
    within "#monitoring_committee_members table" do
      expect(page).to have_content(monitoring_committee_member.user.email)
    end
  end

  context "when creating a new member" do
    let(:existing_user) { create :user, organization: voting.organization }

    before do
      click_link("New member")
    end

    it "creates a new user" do
      within ".new_monitoring_committee_member" do
        fill_in :monitoring_committee_member_email, with: "joe@doe.com"
        fill_in :monitoring_committee_member_name, with: "Joe Doe"

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#monitoring_committee_members table" do
        expect(page).to have_content(other_user.email)
        expect(page).to have_content("joe@doe.com")
      end
    end

    it "uses an existing user" do
      within ".new_monitoring_committee_member" do
        select "Existing participant", from: :monitoring_committee_member_existing_user
        autocomplete_select "#{existing_user.name} (@#{existing_user.nickname})", from: :user_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#monitoring_committee_members table" do
        expect(page).to have_content(other_user.email)
        expect(page).to have_content(existing_user.email)
      end
    end
  end

  context "when deleting a member" do
    it "deletes the member" do
      within find("#monitoring_committee_members tr", text: other_user.email) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#monitoring_committee_members table" do
        expect(page).to have_no_content(other_user.email)
      end
    end
  end
end
