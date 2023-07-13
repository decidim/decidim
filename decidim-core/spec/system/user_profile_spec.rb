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
      within "[data-content]" do
        expect(page).to have_content(user.nickname)
      end
    end

    it "adds a link to edit the profile" do
      within "[data-content]" do
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
      expect(page).to have_selector("h1", text: user.name)
      expect(page).to have_content(user.nickname)
      expect(page).to have_link("Message")
    end

    it "does not show officialization stuff" do
      expect(page).not_to have_content("This participant is publicly verified")
    end

    context "and user officialized the standard way" do
      let(:user) { create(:user, :officialized, officialized_as: nil) }

      it "shows officialization status" do
        expect(page).to have_content("Official participant")
      end
    end

    context "and user officialized with a custom badge" do
      let(:user) do
        create(:user, :officialized, officialized_as: { "en" => "Major of Barcelona" })
      end

      it "shows officialization status" do
        click_link "Badges"
        expect(page).to have_content("Major of Barcelona")
      end
    end

    context "when displaying followers and following" do
      let(:other_user) { create(:user, organization: user.organization) }
      let(:user_to_follow) { create(:user, organization: user.organization) }
      let(:user_group) { create(:user_group, organization: user.organization) }
      let(:public_resource) { create(:dummy_resource, :published) }

      before do
        create(:follow, user:, followable: other_user)
        create(:follow, user:, followable: user_to_follow)
        create(:follow, user: other_user, followable: user)
        create(:follow, user:, followable: user_group)
        create(:follow, user:, followable: public_resource)
      end

      it "shows the number of followers and following" do
        visit decidim.profile_path(user.nickname)
        within(".profile__details") do
          expect(page).to have_content("1 follower")
          expect(page).to have_content("3 follows")
        end
      end

      it "lists the followers" do
        visit decidim.profile_path(user.nickname)
        click_link "Followers"

        expect(page).to have_content(other_user.name)
      end

      it "lists the followings" do
        visit decidim.profile_path(user.nickname)
        click_link "Follows"

        expect(page).not_to have_content("Some of the resources followed are not public.")
        expect(page).to have_content(translated(other_user.name))
        expect(page).to have_content(translated(user_to_follow.name))
        expect(page).to have_content(translated(user_group.name))
        expect(page).not_to have_content(translated(public_resource.title))
      end

      context "when the user follows non public resources" do
        let(:non_public_resource) { create(:user, :blocked) }

        before do
          create(:follow, user:, followable: non_public_resource)
        end

        it "lists only the public followings" do
          visit decidim.profile_path(user.nickname)
          within(".profile__details") do
            expect(page).to have_content("4 follows")
          end

          click_link "Follows"
          expect(page).to have_content("Some of the resources followed are not public.")
          expect(page).to have_content(translated(other_user.name))
          expect(page).to have_content(translated(user_to_follow.name))
          expect(page).to have_content(translated(user_group.name))
          expect(page).not_to have_content(translated(public_resource.title))
          expect(page).not_to have_content(translated(non_public_resource.name))
        end
      end

      context "when the user follows a blocked user" do
        let(:blocked_user) { create(:user, :blocked) }

        before do
          create(:follow, user:, followable: blocked_user)
        end

        it "lists only the unblocked followings" do
          visit decidim.profile_path(user.nickname)

          click_link "Follows"
          expect(page).to have_content("Some of the resources followed are not public.")
          expect(page).to have_content(translated(other_user.name))
          expect(page).to have_content(translated(user_to_follow.name))
          expect(page).to have_content(translated(user_group.name))
          expect(page).not_to have_content(translated(public_resource.title))
        end
      end

      context "when the user is followed by a blocked user" do
        let(:blocked_user) { create(:user, :blocked) }

        before do
          create(:follow, user: blocked_user, followable: user)
        end

        it "lists only the unblocked followers" do
          visit decidim.profile_path(user.nickname)

          click_link "Followers"
          expect(page).to have_content(translated(other_user.name))
          expect(page).not_to have_content(translated(blocked_user.name))
        end
      end
    end

    describe "badges" do
      context "when badges are enabled" do
        before do
          user.organization.update(badges_enabled: true)
          Decidim::Gamification.set_score(user, :test, 10)
          visit decidim.profile_path(user.nickname)
        end

        it "shows a badges tab" do
          expect(page).to have_link("Badges")
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
      end
    end

    context "when belonging to user groups" do
      let!(:accepted_user_group) { create(:user_group, users: [user], organization: user.organization) }
      let!(:pending_user_group) { create(:user_group, users: [], organization: user.organization) }
      let!(:pending_membership) { create(:user_group_membership, user_group: pending_user_group, user:, role: "requested") }

      before do
        visit decidim.profile_path(user.nickname)
      end

      it "lists the user groups" do
        click_link "Groups"

        expect(page).to have_content(accepted_user_group.name)
        expect(page).not_to have_content(pending_user_group.name)
      end

      context "when user groups are disabled" do
        let(:organization) { create(:organization, user_groups_enabled: false) }
        let(:user) { create(:user, :confirmed, organization:) }

        it { is_expected.not_to have_content("Groups") }
      end
    end
  end

  describe "view hooks" do
    before do
      allow(Decidim.view_hooks)
        .to receive(:render)
        .with(a_kind_of(Symbol), a_kind_of(Decidim::ProfileCell))
        .and_return("Rendered from #{view_hook} view hook")

      visit decidim.profile_path(user.nickname)
    end

    context "with user_profile_bottom view hook" do
      let(:view_hook) { :user_profile_bottom }

      it "renders the view hook" do
        expect(Decidim.view_hooks).to have_received(:render).with(:user_profile_bottom, a_kind_of(Decidim::ProfileCell))
        expect(page).to have_content("Rendered from user_profile_bottom view hook")
      end
    end
  end
end
