# frozen_string_literal: true

require "spec_helper"

describe "Timeout", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  let(:organization) { create(:organization) }
  let(:current_user) { create :user, organization: organization }

  context "when session is about to timeout" do
    before do
      switch_to_host(organization.host)
      login_as current_user, scope: :user
      Devise.timeout_in = 2.minutes
    end

    it "timeouts if user does nothing" do
      visit decidim.root_path
      travel 1.minute
      execute_script("Decidim.timeouter(500)")
      expect(page).to have_content("You were inactive for too long", wait: 2)
    end

    it "doesnt timeout when user is active in another window" do
      win1 = current_window
      visit decidim.root_path

      switch_to_window(open_new_window)
      visit decidim.root_path
      execute_script("Decidim.timeouter(1000)")
      2.times.each do
        expect(page).to have_content("If you continue being inactive", wait: 2)
        find("#continueSession").click
        travel 20.seconds
      end

      switch_to_window(win1)
      execute_script("Decidim.timeouter(1000)")
      expect(page).to have_content("If you continue being inactive", wait: 2)
      find("#continueSession").click
      expect(page).not_to have_content("You were inactive for too long")
    end
  end
end
