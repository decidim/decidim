# frozen_string_literal: true

require "spec_helper"

describe "Admin manages polling officers", type: :system do
  include_context "when admin managing a voting"

  let(:other_user) { create :user, organization: organization, email: "my_email@example.org" }
  let!(:polling_officer) { create :polling_officer, user: other_user, voting: voting }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
    click_link "Polling Officers"
  end

  it "shows polling officer list" do
    within "#polling_officers table" do
      expect(page).to have_content(polling_officer.user.email)
    end
  end

  context "when creating a new polling officer" do
    let(:existing_user) { create :user, organization: voting.organization }

    before do
      click_link("New")
    end

    it "creates a new user" do
      within ".new_polling_officer" do
        fill_in :polling_officer_email, with: "joe@doe.com"
        fill_in :polling_officer_name, with: "Joe Doe"

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#polling_officers table" do
        expect(page).to have_content(other_user.email)
        expect(page).to have_content("joe@doe.com")
      end
    end

    it "uses an existing user" do
      within ".new_polling_officer" do
        select "Existing participant", from: :polling_officer_existing_user
        autocomplete_select "#{existing_user.name} (@#{existing_user.nickname})", from: :user_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#polling_officers table" do
        expect(page).to have_content(other_user.email)
        expect(page).to have_content(existing_user.email)
      end
    end
  end

  context "when deleting a polling officer" do
    it "deletes the polling officer" do
      within find("#polling_officers tr", text: other_user.email) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#polling_officers table" do
        expect(page).to have_no_content(other_user.email)
      end
    end
  end
end
