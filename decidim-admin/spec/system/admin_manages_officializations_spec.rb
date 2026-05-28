# frozen_string_literal: true

require "spec_helper"

describe "Admin manages officializations" do
  include_context "with filterable context"

  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::OfficializationsController }

  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_on "Participants"
  end

  describe "listing officializations" do
    let!(:officialized) { create(:user, :officialized, organization:) }
    let!(:not_officialized) { create(:user, organization:) }
    let!(:deleted) do
      user = create(:user, organization:)
      result = Decidim::DestroyAccount.call(OpenStruct.new(valid?: true, delete_reason: "Testing", current_user: user))
      result["ok"]
    end
    let!(:external_not_officialized) { create(:user) }

    before do
      within_admin_sidebar_menu do
        click_on "Participants"
      end
    end

    it_behaves_like "a filtered collection", options: "State", filter: "Officialized" do
      let(:in_filter) { officialized.name }
      let(:not_in_filter) { not_officialized.name }
    end

    it_behaves_like "a filtered collection", options: "State", filter: "Not officialized" do
      let(:in_filter) { not_officialized.name }
      let(:not_in_filter) { officialized.name }
    end

    it_behaves_like "paginating a collection"
  end

  describe "sorting participants by creation date" do
    let!(:newest_user) { create(:user, :confirmed, name: "Newest user", organization:, created_at: 1.day.from_now) }
    let!(:old_user) { create(:user, :confirmed, name: "Old user", organization:, created_at: 3.weeks.ago) }
    let!(:recent_user) { create(:user, :confirmed, name: "Recent user", organization:, created_at: 1.week.ago) }

    before do
      within_admin_sidebar_menu { click_on "Participants" }
    end

    it "sorts by created_at descending when 'Created at' is clicked" do
      within "table thead" do
        click_on "Created At"
      end

      names = page.all("table tbody tr td:first-child").map(&:text)
      expect(names.index("Newest user")).to be < names.index("Recent user")
      expect(names.index("Recent user")).to be < names.index("Old user")
    end

    it "sorts by created_at ascending when clicked again" do
      within "table thead" do
        click_on "Created At"
        click_on "Created At"
      end

      names = page.all("table tbody tr td:first-child").map(&:text)
      expect(names.index("Old user")).to be < names.index("Recent user")
      expect(names.index("Recent user")).to be < names.index("Newest user")
    end
  end

  describe "sorting participants by report count" do
    let!(:user_mid) { create(:user, :confirmed, name: "Mid reports", organization:) }
    let!(:user_no_moderation) { create(:user, :confirmed, name: "No moderation", organization:) }
    let!(:user_zero) { create(:user, :confirmed, name: "Zero reports", organization:) }
    let!(:user_high) { create(:user, :confirmed, name: "High reports", organization:) }

    before do
      create(:user_moderation, user: user_mid, report_count: 1)
      create(:user_moderation, user: user_zero, report_count: 0)
      create(:user_moderation, user: user_high, report_count: 10)
      within_admin_sidebar_menu { click_on "Participants" }
    end

    it "sorts by report count descending when 'Reports' is clicked" do
      within "table thead" do
        click_on "Reports"
      end

      names = page.all("table tbody tr td:first-child").map(&:text)
      expect(names.index("High reports")).to be < names.index("Mid reports")
      expect(names.index("Mid reports")).to be < names.index("Zero reports")
      expect(names.index("Mid reports")).to be < names.index("No moderation")
    end

    it "treats users without a moderation row as zero reports" do
      visit "#{current_path}?q%5Bs%5D=user_moderation_report_count+asc"

      names = page.all("table tbody tr td:first-child").map(&:text)
      no_moderation_idx = names.index("No moderation")
      zero_idx = names.index("Zero reports")
      mid_idx = names.index("Mid reports")
      high_idx = names.index("High reports")

      expect([no_moderation_idx, zero_idx].max).to be < mid_idx
      expect(mid_idx).to be < high_idx
    end
  end

  describe "blocked users" do
    let!(:user) { create(:user, :blocked, organization:) }

    before do
      within_admin_sidebar_menu do
        click_on "Participants"
      end
    end

    context "when user is blocked" do
      it "cannot be officialized" do
        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_no_link("Officialize")
        end
      end
    end
  end

  describe "when user's nickname is blank" do
    let!(:user) { create(:user, :managed, organization:, nickname: "") }

    before do
      within_admin_sidebar_menu do
        click_on "Participants"
      end
    end

    it "has no user link" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        expect(page).to have_text(user.name)
        expect(page).to have_no_link(user.name)
      end
    end
  end

  describe "officializating users" do
    context "when not yet officialized" do
      let!(:user) { create(:user, organization:) }

      before do
        within_admin_sidebar_menu do
          click_on "Participants"
        end

        within "tr[data-user-id=\"#{user.id}\"]" do
          find("button[data-controller='dropdown']").click
          click_on "Officialize"
        end
      end

      it "officializes it with the standard badge" do
        click_on "Officialize"

        expect(page).to have_callout("Participant successfully officialized")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_text("Officialized")
        end
      end

      it "officializes it with a custom badge" do
        fill_in_i18n(
          :officialization_officialized_as,
          "#officialization-officialized_as-tabs",
          en: "Major of Barcelona",
          es: "Alcaldesa de Barcelona"
        )

        click_on "Officialize"

        expect(page).to have_callout("Participant successfully officialized")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_text("Officialized").and have_text("Major of Barcelona")
        end
      end
    end

    context "when officialized already" do
      let!(:user) do
        create(
          :user,
          :officialized,
          officialized_as: { "en" => "Mayor of Barcelona" },
          organization:
        )
      end

      before do
        within_admin_sidebar_menu do
          click_on "Participants"
        end

        within "tr[data-user-id=\"#{user.id}\"]" do
          find("button[data-controller='dropdown']").click
          click_on "Reofficialize"
        end
      end

      it "allows changing the officialization label" do
        expect(page).to have_field("officialization_officialized_as_en", with: "Mayor of Barcelona")

        fill_in_i18n(
          :officialization_officialized_as,
          "#officialization-officialized_as-tabs",
          en: "Major of Barcelona"
        )
        click_on "Officialize"

        expect(page).to have_callout("Participant successfully officialized")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_text("Officialized").and have_text("Major of Barcelona")
        end
      end
    end
  end

  describe "unofficializating users" do
    let!(:user) { create(:user, :officialized, organization:) }

    before do
      within_admin_sidebar_menu do
        click_on "Participants"
      end

      within "tr[data-user-id=\"#{user.id}\"]" do
        find("button[data-controller='dropdown']").click
        click_on "Unofficialize"
      end
    end

    it "unofficializes user and goes back to list" do
      expect(page).to have_callout("Participant successfully unofficialized")

      within "tr[data-user-id=\"#{user.id}\"]" do
        expect(page).to have_text("Not officialized")
      end
    end
  end

  describe "contacting the user" do
    let!(:user) { create(:user, organization:) }

    before do
      within_admin_sidebar_menu do
        click_on "Participants"
      end
    end

    it "redirect to conversation path" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        find("button[data-controller='dropdown']").click
        click_on "Send message"
      end
      expect(page).to have_current_path decidim.new_conversation_path(recipient_id: user.id)
    end
  end

  describe "clicking on user name" do
    let!(:user) { create(:user, organization:) }

    before do
      within_admin_sidebar_menu do
        click_on "Participants"
      end
    end

    it "redirect to user profile page" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        click_on user.name
      end

      within "div.profile__details" do
        expect(page).to have_text(user.name)
      end
    end
  end

  describe "clicking on user nickname" do
    let!(:user) { create(:user, organization:) }

    before do
      within_admin_sidebar_menu do
        click_on "Participants"
      end
    end

    it "redirect to user profile page" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        click_on user.nickname
      end

      within "div.profile__details" do
        expect(page).to have_text(user.name)
      end
    end
  end

  describe "retrieving the user email address" do
    let!(:users) { create_list(:user, 3, organization:) }

    before do
      within_admin_sidebar_menu do
        click_on "Participants"
      end
    end

    it "shows the users emails to admin users and logs the action" do
      users.each do |user|
        within "tr[data-user-id=\"#{user.id}\"]" do
          find("button[data-controller='dropdown']").click
          click_on "Show email"
        end

        within "#show-email-modal" do
          expect(page).to have_text("Show participant's email address")
          expect(page).to have_no_text(user.email)

          click_on "Show"

          expect(page).to have_text(user.email)

          find("button[data-dialog-close]").click
        end
      end

      visit decidim_admin.root_path

      users.each do |user|
        expect(page).to have_text("#{admin.name} retrieved the email of the participant #{user.name}")
      end
    end
  end
end
