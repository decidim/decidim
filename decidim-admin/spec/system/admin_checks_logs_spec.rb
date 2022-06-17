# frozen_string_literal: true

require "spec_helper"

describe "Admin checks logs", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:action_logs) { create_list :action_log, 3, organization: }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  it "lists all recent logs" do
    click_link "Admin activity log"

    expect(page).to have_content("Admin log")

    within ".content" do
      expect(page).to have_selector("li", count: 3)
    end
  end
end
