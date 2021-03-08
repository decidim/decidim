# frozen_string_literal: true

require "spec_helper"

describe "Session timeout", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  let(:organization) { create(:organization) }
  let(:current_user) { create :user, organization: organization }

  context "when session is about to timeout" do
    before do
      allow(Devise).to receive(:timeout_in).and_return(2.minutes)
      allow(Decidim.config).to receive(:session_timeouter_interval).and_return(1000)
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    it "timeouts if the user idles for too long" do
      visit decidim.root_path
      travel 1.minute
      expect(page).to have_content("You were inactive for too long", wait: 3)
    end

    it "doesnt timeout when user is active in another window" do
      win1 = current_window
      visit decidim.root_path

      switch_to_window(open_new_window)
      visit decidim.root_path
      2.times.each do
        expect(page).to have_content("If you continue being inactive", wait: 3)
        find("#continueSession").click
        travel 20.seconds
      end

      switch_to_window(win1)
      expect(page).to have_content("If you continue being inactive", wait: 3)
      find("#continueSession").click
      expect(page).not_to have_content("You were inactive for too long")
    end
  end
end
