# frozen_string_literal: true

require "spec_helper"

describe "Continuity Tracker", type: :system do
  let(:user) { create(:user, :confirmed) }
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "tracks the user's continuity" do
    visit decidim.root_path
    expect(page).to have_content organization.name

    status = Decidim::ContinuityBadgeStatus.find_by(subject: user)
    expect(status).to have_attributes(current_streak: 1, last_session_at: Time.zone.today)
  end
end
