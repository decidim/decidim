# frozen_string_literal: true

require "spec_helper"

describe "Session timeout", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  let(:organization) { create(:organization) }
  let(:current_user) { create :user, organization: organization }

  context "when session is about to timeout" do
    before do
      Devise.timeout_in = 2.minutes
      Rails.application.config.session_timeouter_interval = 1000
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    it "timeouts if the user idles for too long" do
      visit decidim.root_path
      travel 1.minute
      expect(page).to have_content("You were inactive for too long", wait: 2)
    end

    it "doesnt timeout when user is active in another window" do
      win1 = current_window
      visit decidim.root_path

      switch_to_window(open_new_window)
      visit decidim.root_path
      2.times.each do
        expect(page).to have_content("If you continue being inactive", wait: 2)
        find("#continueSession").click
        travel 20.seconds
      end

      switch_to_window(win1)
      expect(page).to have_content("If you continue being inactive", wait: 2)
      find("#continueSession").click
      expect(page).not_to have_content("You were inactive for too long")
    end
  end
end
