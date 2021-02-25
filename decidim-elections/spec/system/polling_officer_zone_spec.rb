# frozen_string_literal: true

require "spec_helper"

describe "Polling Officer zone", type: :system do
  let(:organization) { create(:organization, :secure_context) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:polling_officers) { [assigned_polling_officer, unassigned_polling_officer] }
  let(:voting) { create(:voting, organization: organization) }
  let(:other_voting) { create(:voting, organization: organization) }
  let(:polling_station) { create(:polling_station, voting: voting) }
  let(:assigned_polling_officer) { create(:polling_officer, voting: voting, user: user, presided_polling_station: polling_station) }
  let(:unassigned_polling_officer) { create(:polling_officer, voting: other_voting, user: user) }

  before do
    polling_officers
    switch_to_secure_context_host
    login_as user, scope: :user
  end

  it "can access to the polling officer zone" do
    visit decidim.account_path

    expect(page).to have_content("Polling Officer zone")

    click_link "Polling Officer zone"

    expect(page).to have_content(translated(voting.title))
    expect(page).to have_content(translated(other_voting.title))
  end

  context "when the user is not a polling officer" do
    let(:polling_officers) { [create(:polling_officer)] }

    it "can't access to the polling officer zone" do
      visit decidim.account_path

      expect(page).not_to have_content("Polling Officer zone")

      visit decidim.decidim_elections_trustee_zone_path

      expect(page).to have_content("You are not authorized to perform this action")

      expect(page).to have_current_path(decidim.root_path)
    end
  end
end
