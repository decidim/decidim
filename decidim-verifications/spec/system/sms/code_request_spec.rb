# frozen_string_literal: true

require "spec_helper"

describe "SMS code request", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ["sms"])
  end

  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_sms.root_path
  end

  it "redirects to verification after login" do
    expect(page).to have_content("Request your verification code")
  end

  context "when requesting a code by sms" do
    before do
      fill_in "Mobile phone number", with: "600102030"
      click_button "Send me an SMS"
    end

    it "allows the user to request a code by sms to get verified" do
      expect(page).to have_content("Thanks! We've sent an SMS to your phone")
    end
  end
end
