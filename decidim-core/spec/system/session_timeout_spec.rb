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
      win1 = current_window
      Devise.timeout_in = 2.minutes
      visit decidim.root_path
      puts "START"
      win2 = open_new_window
      switch_to_window(win2)
      visit decidim.root_path
      puts "FIRST CLICK (20s)"
      find(".logo-wrapper", wait: 20).click
      puts "SECOND CLICK (20s)"
      find(".logo-wrapper", wait: 20).click
      puts "THIRD CLICK (20s)"
      find(".logo-wrapper", wait: 20).click

      switch_to_window(win1)

      puts "HAVE TEST CONTENT (11s = 20*3+11)"
      expect(page).to have_content("DIFF IN SECONDS", wait: 11)
      puts "71s =>"
      puts find("#test_element").text.inspect
      expect(page).to have_content("TIME LEFT ASKING DONE")
      expect(page).to have_content("If you continue being inactive")
      puts "WAITING FOR INACTIVITY (20s)"
      expect(page).not_to have_content("You were inactive for too long", wait: 20)
      puts "91s =>"
    end
  end
end
