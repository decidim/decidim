# frozen_string_literal: true

require "spec_helper"

describe "Gamification", type: :system do
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
        click_link "Badges"
        within ".badge-test" do
          expect(page).to have_content "Level 2"
        end
      end
    end
  end

  context "with a user group" do
    describe "profile badges" do
      let!(:user_group) { create(:user_group, organization:) }

      before do
        Decidim::Gamification.set_score(user_group, :test, 5)
      end

      it "shows a list of badges" do
        visit decidim.profile_path(user_group.nickname)
        click_link "Badges"
        within ".badge-test" do
          expect(page).to have_content "Level 2"
        end
      end
    end
  end

  describe "badges info page" do
    let!(:user) { create(:user, organization:) }

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
      expect(page).to have_content "Tests badge"
      expect(page).to have_content "Participants get this badge by creating tests"
      expect(page).to have_content "Use a test environment for decidim"
    end
  end
end
