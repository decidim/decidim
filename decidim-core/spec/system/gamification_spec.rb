# frozen_string_literal: true

require "spec_helper"

describe "Gamification" do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "with a user" do
    describe "profile badges" do
      let!(:user) { create(:user, organization:) }

      before do
        Decidim::Gamification.set_score(user, :test, 5)
      end

      it "shows a list of badges" do
        visit decidim.profile_path(user.nickname)
        click_on "Badges"
        within "div[data-badge='test']" do
          expect(page).to have_content "Level 2"
        end
      end
    end
  end

  describe "badges info page" do
    let!(:user) { create(:user, organization:) }

    it "can be reached from the profile's badges page" do
      visit decidim.profile_path(user.nickname)
      click_on "Badges"
      within ".profile__badge-banner" do
        click_on "See all available badges"
      end

      expect(page).to have_current_path(decidim.gamification_badges_path)
    end

    it "shows a list of available badges" do
      visit decidim.gamification_badges_path
      expect(page).to have_content "Tests badge"
      expect(page).to have_content "Participants get this badge by creating tests"
      expect(page).to have_content "Use a test environment for decidim"
    end
  end
end
