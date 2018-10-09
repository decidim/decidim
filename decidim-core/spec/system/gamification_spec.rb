# frozen_string_literal: true

require "spec_helper"

describe "Gamification", type: :system do
  let!(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "profile badges" do
    before do
      Decidim::Gamification.set_score(user, :test, 5)
    end

    it "shows a list of badges" do
      visit decidim.profile_path(user.nickname)
      click_link "Badges"
      within ".badge-test" do
        expect(page).to have_content "LEVEL 2"
      end
    end
  end

  describe "badges info page" do
    it "can be reached from the profile's badges page" do
      visit decidim.profile_path(user.nickname)
      click_link "Badges"
      within ".tabs-panel.is-active" do
        click_link "See all available badges"
      end
      expect(page).to have_current_path(decidim.gamification_badges_path)
    end

    it "shows a list of available badges" do
      visit decidim.gamification_badges_path
      expect(page).to have_content "Test badge"
      expect(page).to have_content "This is a dummy badge"
      expect(page).to have_content "Use a test environment for decidim"
    end
  end
end
