# frozen_string_literal: true

require "spec_helper"

describe "Session timeout", type: :system do
  let(:organization) { create(:organization) }
  let(:current_user) { create :user, organization: organization }

  context "when session is about to timeout" do
    before do
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    it "shows modal" do
      Devise.timeout_in = 2.minutes
      visit decidim.root_path
      expect(page).to have_content("If you continue being inactive", wait: 11)
    end

    it "timeouts if user does nothing" do
      Devise.timeout_in = 1.minute
      visit decidim.root_path
      expect(page).to have_content("You were inactive for too long", wait: 15)
    end

    it "doesnt timeout when user is active in another window" do
      Devise.timeout_in = 2.minutes
      win1 = current_window
      visit decidim.root_path

      switch_to_window(open_new_window)
      visit decidim.root_path
      expect(page).to have_content("If you continue being inactive", wait: 11)
      find("#continueSession").click
      expect(page).to have_content("If you continue being inactive", wait: 11)
      find("#continueSession").click
      expect(page).to have_content("If you continue being inactive", wait: 11)
      find("#continueSession").click

      switch_to_window(win1)
      expect(page).not_to have_content("You were inactive for too long")
    end
  end
end
