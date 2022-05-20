# frozen_string_literal: true

require "spec_helper"

describe "Account", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, password: password, password_updated_at: password_updated_at, organization: organization) }
  let(:password) { "decidim123456" }
  let(:password_updated_at) { nil }

  context "when admin needs to update password" do
    let(:new_password) { "decidimadmin123456" }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "can update password successfully" do
      manual_login(user.email, password)
      expect(page).to have_content("Change your password")
      fill_in :password_user_password, with: new_password
      fill_in :password_user_password_confirmation, with: new_password
      click_button "Change my password"
      expect(page).to have_css(".callout.success")
      expect(user.reload.password_updated_at).to be_between(2.seconds.ago, Time.current)
    end

    context "when user had previously strong password" do
      let(:password) { new_password }

      it "cant reuse old password" do
        manual_login(user.email, password)
        expect(page).to have_content("Change your password")
        fill_in :password_user_password, with: new_password
        fill_in :password_user_password_confirmation, with: new_password
        click_button "Change my password"
        expect(page).to have_css(".callout.alert")
        expect(page).to have_content("can't reuse old password")
      end
    end
  end

  def manual_login(email, password)
    click_link "Sign In"
    fill_in :session_user_email, with: email
    fill_in :session_user_password, with: password
    click_button "Log in"
  end
end
