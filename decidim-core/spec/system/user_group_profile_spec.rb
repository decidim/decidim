# frozen_string_literal: true

require "spec_helper"

describe "User group profile" do
  let(:user) { create(:user, :confirmed) }
  let(:user_group) { create(:user_group, :confirmed, users: [user], organization: user.organization) }

  before do
    switch_to_host(user_group.organization.host)
  end

  context "when navigating privately" do
    before do
      login_as user, scope: :user
      visit decidim.profile_path(nickname: user_group.nickname)
    end

    it "adds a link to conversations" do
      click_on "Conversations", class: "profile__tab-item"

      expect(page).to have_current_path(decidim.profile_conversations_path(nickname: user_group.nickname))
    end
  end

  context "when navigating publicly" do
    before do
      visit decidim.profile_path(nickname: user_group.nickname)
    end

    it "does not have a link to conversations" do
      expect(page).to have_no_css("a.profile__tab-item", text: "Conversations")
    end

    it "shows user group name in the header and its nickname" do
      expect(page).to have_css("h1", text: user_group.name)
      expect(page).to have_content(user_group.nickname)
    end

    context "when displaying followers" do
      let(:other_user) { create(:user, organization: user_group.organization) }

      before do
        create(:follow, user: other_user, followable: user_group)
        visit decidim.profile_path(nickname: user_group.nickname)
      end

      it "shows the number of followers and following" do
        expect(page).to have_content("1 follower")
      end

      it "lists the followers" do
        click_on "Followers"

        expect(page).to have_content(other_user.name)
      end
    end

    context "when displaying members" do
      let!(:pending_user) { create(:user, organization: user.organization) }
      let!(:pending_membership) { create(:user_group_membership, user_group:, user: pending_user, role: "requested") }

      it "lists the members" do
        expect(page).to have_css("div.profile__user-grid", count: 1)
        click_on "Members"

        expect(page).to have_content(user.name)
        expect(page).to have_no_content(pending_user.name)
      end
    end
  end
end
