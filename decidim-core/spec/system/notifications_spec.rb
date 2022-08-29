# frozen_string_literal: true

require "spec_helper"

describe "Notifications", type: :system do
  let(:resource) { create :dummy_resource }
  let(:participatory_space) { resource.component.participatory_space }
  let(:organization) { participatory_space.organization }
  let!(:user) { create :user, :confirmed, organization: }
  let!(:notification) { create :notification, user:, resource: }

  before do
    switch_to_host organization.host
    login_as user, scope: :user
  end

  describe "accessing the notifications page" do
    before do
      page.visit decidim.root_path
    end

    it "has a button on the topbar nav that links to the notifications page" do
      within ".topbar__user__logged" do
        find("a.topbar__notifications").click
      end

      expect(page).to have_current_path decidim.notifications_path
      expect(page).to have_no_content("No notifications yet")
      expect(page).to have_content("An event occured")
    end

    context "when the resource has been deleted" do
      before do
        resource.destroy!
        page.visit decidim.root_path
      end

      it "displays nothing" do
        within ".topbar__user__logged" do
          find("a.topbar__notifications").click
        end

        expect(page).to have_current_path decidim.notifications_path
        expect(page).to have_content("No notifications yet")
      end
    end

    context "when there are no notifications" do
      let!(:notification) { nil }

      it "the button is not shown as active" do
        within ".topbar__user__logged" do
          expect(page).to have_no_selector("a.topbar__notifications.is-active")
          expect(page).to have_selector("a.topbar__notifications")
        end
      end
    end

    context "when there are some notifications" do
      it "the button is shown as active" do
        within ".topbar__user__logged" do
          expect(page).to have_selector("a.topbar__notifications.is-active")
        end
      end
    end
  end

  context "when no notification is found" do
    let!(:notification) { nil }

    before do
      page.visit decidim.notifications_path
    end

    it "doesn't show any notification" do
      expect(page).not_to have_content("Mark all as read")
      expect(page).to have_content("No notifications yet")
    end
  end

  context "with notifications" do
    before do
      page.visit decidim.notifications_path
    end

    it "shows the notifications" do
      expect(page).to have_selector(".card.card--widget")
    end

    context "when setting a single notification as read" do
      let(:notification_title) { "An event occured to #{translated resource.title}" }

      it "hides the notification from the page" do
        expect(page).to have_content(translated(notification_title))
        find(".mark-as-read-button").click
        expect(page).to have_no_content(translated(notification_title))
        expect(page).to have_content("No notifications yet")
      end
    end

    context "when setting all notifications as read" do
      it "hides all notifications from the page" do
        click_link "Mark all as read"
        expect(page).not_to have_selector("#notifications")
        expect(page).to have_content("No notifications yet")

        within ".title-bar" do
          expect(page).to have_css(".topbar__notifications")
          expect(page).not_to have_css(".topbar__notifications.is-active")
        end
      end
    end
  end

  context "with user group mentioned notifications" do
    let(:event_class) { "Decidim::Comments::UserGroupMentionedEvent" }
    let(:event_name) { "decidim.events.comments.user_group_mentioned" }
    let(:extra) { { comment_id: create(:comment).id, group_id: create(:user_group).id } }
    let!(:notification) { create :notification, user:, event_class:, event_name:, extra: }

    before do
      page.visit decidim.notifications_path
    end

    it "shows the notification with the group mentioned" do
      group = Decidim::UserGroup.find(notification.extra["group_id"])
      element = page.find(".card-data__item--expand")
      notification_text = element.text

      expect(notification_text).to include("as a member of #{group.name} @#{group.nickname}")
    end
  end
end
