# frozen_string_literal: true

require "spec_helper"

describe "Instant validations", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when in registration form" do
    let!(:user) { create(:user, organization: organization, email: "bot@matrix.org", nickname: "agentsmith") }

    it "Email is validated while writing" do
      within("#register-form") do
        expect(page).not_to have_content("Is invalid")

        fill_in "Your email", with: " bot@matrix"
        sleep 0.2 # wait for the delayed triggering fetcher

        expect(page).to have_content("Is invalid")
      end
    end

    it "Password is validated while writing" do
      within("#register-form") do
        expect(page).not_to have_content("Is too short")

        fill_in "Password", with: "mypas"
        sleep 0.2 # wait for the delayed triggering fetcher

        expect(page).to have_content("Is too short")
      end
    end

    it "Password validates against dynamic content" do
      within("#register-form") do
        expect(page).not_to have_content("Is too similar to your name")

        fill_in "Your name", with: "Agent Smith 1984"
        fill_in "Password", with: "agentsmith1984"
        sleep 0.2 # wait for the delayed triggering fetcher

        expect(page).to have_content("Is too similar to your name")

        expect(page).not_to have_content("Is too common")

        fill_in "Password", with: "password11"
        sleep 0.2 # wait for the delayed triggering fetcher

        expect(page).to have_content("Is too common")
      end
    end
  end
end
