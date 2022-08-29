# frozen_string_literal: true

require "spec_helper"

describe "Admin verifies user groups via CSV", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  let!(:user_group) do
    create(
      :user_group,
      :confirmed,
      email: "my_usergroup@example.org", # hardcoded in the CSV file
      organization:,
      users: [create(:user, organization:)]
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
    click_link "Participants"
    click_link "Groups"
    click_link "Verify via CSV"
  end

  it "verifies a batch of user groups" do
    expect(user_group).not_to be_verified

    # The CSV has headers, we're testing we ignore them
    expect(Decidim::Admin::VerifyUserGroupFromCsvJob).to receive(:perform_later).once.ordered.with("Email", user, organization)
    expect(Decidim::Admin::VerifyUserGroupFromCsvJob).to receive(:perform_later).once.ordered.with(user_group.email, user, organization)
    dynamically_attach_file(:user_group_csv_verification_file, Decidim::Dev.asset("verify_user_groups.csv"))
    perform_enqueued_jobs { click_button "Upload" }

    expect(page).to have_content("CSV file uploaded successfully")
  end
end
