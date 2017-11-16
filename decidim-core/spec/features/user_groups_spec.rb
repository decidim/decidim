# frozen_string_literal: true

require "spec_helper"

describe "User groups", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    create(:user_group_membership, user: user, user_group: user_group)
    login_as user, scope: :user
  end

  context "when the user group is pending" do
    let(:user_group) { create(:user_group) }

    it "the user can check its status on his account page" do
      visit decidim.own_user_groups_path

      click_link "Organizations"

      expect(page).to have_content(user_group.name)
      expect(page).to have_content("Pending")
    end

    describe "#verified?" do
      it "returns false" do
        expect(user_group.verified?).to eq(false)
      end
    end
  end

  context "when the user group is rejected" do
    let(:user_group) { create(:user_group, :rejected) }

    it "the user can check its status on his account page" do
      visit decidim.own_user_groups_path

      click_link "Organizations"

      expect(page).to have_content(user_group.name)
      expect(page).to have_content("Rejected")
    end
  end

  context "when the user group is verified" do
    let(:user_group) { create(:user_group, :verified) }

    it "the user can check its status on his account page" do
      visit decidim.own_user_groups_path

      click_link "Organizations"

      expect(page).to have_content(user_group.name)
      expect(page).to have_content("Verified")
    end

    describe "#verified?" do
      it "returns true" do
        expect(user_group.verified?).to eq(true)
      end
    end
  end
end
