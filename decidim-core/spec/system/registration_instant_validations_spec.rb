# frozen_string_literal: true

require "spec_helper"

describe "Instant validations", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when in registration form" do
    it "Nickname is suggested on writing the name" do
      within("#register-form") do
        expect(page).not_to have_content("agentsmith")

        fill_in "Your name", with: " Agent Smith"
        sleep 0.2 # wait for the delayed triggering fetcher

        expect(page.evaluate_script("document.getElementById('registration_user_nickname').value")).to eq("agentsmith")
      end
    end
  end
end
