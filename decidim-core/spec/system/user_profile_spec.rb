# frozen_string_literal: true

require "spec_helper"

describe "Profile", type: :system do
  let(:user) { create(:user, :confirmed) }

  before do
    switch_to_host(user.organization.host)
  end

  context "when navigating privately" do
    before do
      login_as user, scope: :user

      visit decidim.root_path

      within_user_menu do
        find("a", text: "profile").click
      end
    end

    it "shows the profile page when clicking on the menu" do
      within "main.wrapper" do
        expect(page).to have_content(user.nickname)
      end
    end

    it "adds a link to edit the profile" do
      within "main.wrapper" do
        click_link "Edit profile"
      end

      expect(page).to have_current_path(decidim.account_path)
    end
  end

  context "when navigating publicly" do
    before do
      visit decidim.profile_path(user.nickname)
    end

    it "shows user name in the header, its nickname and a contact link" do
      expect(page).to have_selector("h5", text: user.name)
      expect(page).to have_content(user.nickname)
      expect(page).to have_link("Contact")
    end

    it "does not show officialization stuff" do
      expect(page).to have_no_content("This participant is publicly verified")
    end

    context "and user officialized the standard way" do
      let(:user) { create(:user, :officialized, officialized_as: nil) }

      it "shows officialization status" do
        expect(page).to have_content("This participant is publicly verified")
      end
    end

    context "and user officialized with a custom badge" do
      let(:user) do
        create(:user, :officialized, officialized_as: { "en" => "Major of Barcelona" })
      end

      it "shows officialization status" do
        expect(page).to have_content("Major of Barcelona")
      end
    end

    context "when displaying followers and following" do
      let(:other_user) { create(:user, organization: user.organization) }
      let(:user_to_follow) { create(:user, organization: user.organization) }
      let!(:something_that_should_not_be_counted) { create(:follow, user: user, followable: build(:dummy_resource)) }

      before do
        create(:follow, user: user, followable: other_user)
        create(:follow, user: user, followable: user_to_follow)
        create(:follow, user: other_user, followable: user)
        visit decidim.profile_path(user.nickname)
      end

      it "shows the number of followers and following" do
        expect(page).to have_link("Followers 1")
        expect(page).to have_link("Follows 2")
      end

      it "lists the followers" do
        click_link "Followers"

        expect(page).to have_content(other_user.name)
      end

      it "lists the followings" do
        click_link "Follows"

        expect(page).to have_content(other_user.name)
        expect(page).to have_content(user_to_follow.name)
      end
    end

    describe "badges" do
      context "when badges are enabled" do
        before do
          user.organization.update(badges_enabled: true)
          visit decidim.profile_path(user.nickname)
        end

        it "shows a badges tab" do
          expect(page).to have_link("Badges")
        end

        it "shows a badges section on the sidebar" do
          within ".profile--sidebar" do
            expect(page).to have_content("Badges")
          end
        end
      end

      context "when badges are disabled" do
        before do
          user.organization.update(badges_enabled: false)
          visit decidim.profile_path(user.nickname)
        end

        it "shows a badges tab" do
          expect(page).not_to have_link("Badges")
        end

        it "doesn't have a badges section on the sidebar" do
          within ".profile--sidebar" do
            expect(page).not_to have_content("Badges")
          end
        end
      end
    end

    context "when belonging to user groups" do
      let!(:user_group) { create :user_group, users: [user], organization: user.organization }

      before do
        visit decidim.profile_path(user.nickname)
      end

      it "lists the user groups" do
        click_link "Groups"

        expect(page).to have_content(user_group.name)
      end
    end
  end

  describe "view hooks" do
    before do
      allow(Decidim.view_hooks)
        .to receive(:render)
        .with(a_kind_of(Symbol), a_kind_of(Decidim::ProfileSidebarCell))
        .and_return("Rendered from #{view_hook} view hook")

      visit decidim.profile_path(user.nickname)
    end

    context "with user_profile_bottom view hook" do
      let(:view_hook) { :user_profile_bottom }

      it "renders the view hook" do
        expect(Decidim.view_hooks).to have_received(:render).with(:user_profile_bottom, a_kind_of(Decidim::ProfileSidebarCell))
        expect(page).to have_content("Rendered from user_profile_bottom view hook")
      end
    end
  end
end
