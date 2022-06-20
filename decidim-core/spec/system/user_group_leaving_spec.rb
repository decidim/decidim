# frozen_string_literal: true

require "spec_helper"

describe "User group leaving", type: :system do
  let!(:user) { create(:user, :confirmed) }
  let!(:user_group) { create(:user_group, users: [], organization: user.organization) }

  before do
    switch_to_host(user_group.organization.host)
    login_as user, scope: :user
    visit decidim.profile_path(user_group.nickname)
  end

  context "when the user already belongs to the group" do
    context "when the user is the creator" do
      let!(:user_group) { create(:user_group, users: [user], organization: user.organization) }

      it "cant leave group" do
        accept_confirm { click_link "Leave group" }

        expect(page).to have_content("You can't remove yourself from this group as you're the last administrator")
      end

      context "when there is another admin in the group" do
        let(:another_admin) { create(:user, :confirmed, organization: user.organization) }

        before do
          create :user_group_membership, user: another_admin, user_group: user_group, role: :admin
          visit decidim.profile_path(user_group.nickname)
        end

        it "can leave the group" do
          accept_confirm { click_link "Leave group" }

          expect(page).to have_content("Group successfully abandoned")
          expect(page).not_to have_content("Leave group")
        end
      end
    end

    context "when there is two admins in the group" do
      let(:another_user) { create(:user, :confirmed, organization: user.organization) }

      before do
        create :user_group_membership, user: user, user_group: user_group, role: :admin
        create :user_group_membership, user: another_user, user_group: user_group, role: :admin
      end

      it "allows the user to leave and join back" do
        visit decidim.profile_path(user_group.nickname)

        accept_confirm { click_link "Leave group" }

        expect(page).to have_content("Group successfully abandoned")
        expect(page).to have_content("Request to join group")
      end
    end
  end

  context "when the user does not belong to the group" do
    it "does not show the link to leave" do
      expect(page).to have_no_content("Leave group")
    end
  end
end
