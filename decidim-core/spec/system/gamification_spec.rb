# frozen_string_literal: true

require "spec_helper"

describe "Gamification", type: :system do
  let!(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "badges" do
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
end
