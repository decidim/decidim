# frozen_string_literal: true

require "spec_helper"

describe "Notifications", type: :system do
  let(:resource) { create :dummy_resource }
  let(:participatory_space) { resource.component.participatory_space }
  let(:organization) { participatory_space.organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:notification) { create :notification, user: user, resource: resource }

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

  context "with comment notifications" do
    let!(:notification) { create :notification, :comment_notification, user: user }

    before do
      page.visit decidim.notifications_path
    end

    it "shows the comment notification with the conversation link" do
      comment_id = notification.extra["comment_id"]
      comment_definition_string = "commentId=#{comment_id}#comment_#{comment_id}"
      links = page.all(".card.card--widget a")
      hrefs = links.find { |link| link[:href].include?(comment_definition_string) }

      expect(hrefs).not_to be(nil)
    end
  end
end
