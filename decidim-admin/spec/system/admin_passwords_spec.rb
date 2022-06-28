# frozen_string_literal: true

require "spec_helper"

describe "Admin passwords", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, password: password, password_updated_at: password_updated_at, organization: organization) }
  let(:password) { "decidim123456789" }
  let(:new_password) { "decidim987654321" }
  let(:password_updated_at) { nil }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when admin has not updated their password" do
    let(:password_updated_at) { nil }

    it "can update password successfully" do
      manual_login(user.email, password)
      expect(page).to have_content("Admin users need to change their password every 90 days")
      expect(page).to have_content("Password change")
      fill_in :password_user_password, with: new_password
      click_button "Change my password"
      expect(page).to have_css(".callout.success")
      expect(page).to have_content("Password successfully updated")
      expect(user.reload.password_updated_at).to be_between(2.seconds.ago, Time.current)
    end

    it "cannot dismiss password change" do
      manual_login(user.email, password)
      expect(page).to have_content("Password change")
      click_link "user-menu-control"
      click_link "Admin dashboard"
      expect(page).to have_content("You need to change your password in order to proceed further")
      expect(page).to have_content("Password change")
      expect(page).to have_current_path(decidim.change_password_path)
    end

    context "when user is in different path" do
      before do
        visit decidim_admin.root_path
      end

      it "redirects to original path after password update" do
        manual_login(user.email, password)
        expect(page).to have_content("Password change")
        fill_in :password_user_password, with: new_password
        click_button "Change my password"
        expect(page).to have_css(".callout.success")
        expect(page).to have_current_path(decidim_admin.root_path)
      end
    end
  end

  context "when users password is expired" do
    let(:password_updated_at) { 91.days.ago }

    it "redirects to edit password view" do
      manual_login(user.email, password)
      expect(page).to have_content("Password change")
    end
  end

  def manual_login(email, password)
    click_link "Sign In"
    fill_in :session_user_email, with: email
    fill_in :session_user_password, with: password
    click_button "Log in"
  end
end
