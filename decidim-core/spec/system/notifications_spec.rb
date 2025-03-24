# frozen_string_literal: true

require "spec_helper"

describe "Notifications" do
  let(:resource) { create(:dummy_resource) }
  let(:participatory_space) { resource.component.participatory_space }
  let(:organization) { participatory_space.organization }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:notification) { create(:notification, user:, resource:) }

  before do
    switch_to_host organization.host
    login_as user, scope: :user
  end

  describe "accessing the notifications page" do
    before do
      page.visit decidim.root_path
    end

    it "has a button on the topbar nav that links to the notifications page" do
      find_by_id("trigger-dropdown-account").click
      within "#dropdown-menu-account" do
        click_on("Notifications")
      end

      expect(page).to have_current_path decidim.notifications_path
      expect(page).to have_no_content("No notifications yet")
      expect(page).to have_content("An event occurred")
    end

    context "when the resource has been deleted" do
      before do
        resource.destroy!
        page.visit decidim.root_path
      end

      it "displays nothing" do
        find_by_id("trigger-dropdown-account").click
        within "#dropdown-menu-account" do
          click_on("Notifications")
        end

        expect(page).to have_current_path decidim.notifications_path
        expect(page).to have_content("No notifications yet")
      end
    end

    context "when there are no notifications" do
      let!(:notification) { nil }

      it "the button is not shown as active" do
        within ".main-bar" do
          expect(page).to have_no_selector("[data-unread-items]")
        end
      end
    end

    context "when there are some notifications" do
      it "the button is shown as active" do
        within ".main-bar" do
          expect(page).to have_css("[data-unread-items]")
        end
      end
    end
  end

  context "when no notification is found" do
    let!(:notification) { nil }

    before do
      page.visit decidim.notifications_path
    end

    it "does not show any notification" do
      expect(page).to have_no_content("Mark all as read")
      expect(page).to have_content("No notifications yet")
    end
  end

  context "with notifications" do
    before do
      page.visit decidim.notifications_path
    end

    it "shows the notifications" do
      expect(page).to have_css(".notification")
    end

    context "when setting a single notification as read" do
      let(:notification_title) { "An event occurred to #{translated resource.title}" }

      it "hides the notification from the page" do
        expect(page).to have_content(decidim_sanitize_translated(notification_title))
        find("[data-notification-read]").click
        expect(page).to have_no_content(translated(notification_title))
        expect(page).to have_content("No notifications yet")
      end
    end

    context "when setting all notifications as read" do
      it "hides all notifications from the page" do
        click_on "Mark all as read"
        expect(page).to have_no_selector("[data-notification]")
        expect(page).to have_no_content("Mark all as read")
        expect(page).to have_content("No notifications yet")

        within ".main-bar" do
          expect(page).to have_no_selector("[data-unread-items]")
        end
      end
    end
  end

  context "when the notification event has an action" do
    let(:url) { "/api?query=%7Bdecidim%20%7B%20version%20%7D%7D" }
    let(:data) do
      [
        {
          label: "Test button",
          method: "post",
          url:
        }
      ]
    end

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::Dev::DummyResourceEvent).to receive(:action_cell).and_return("decidim/notification_actions/buttons")
      allow_any_instance_of(Decidim::Dev::DummyResourceEvent).to receive(:action_data).and_return(data)
      # rubocop:enable RSpec/AnyInstance
      page.visit decidim.notifications_path
    end

    it "shows the notification with the action buttons" do
      within "#notifications" do
        click_on "Test button"
        expect(page).to have_no_content("Test button")
      end
    end

    context "when the request fails" do
      let(:url) { "/i-do-not-exist" }

      before do
        allow(page.config).to receive(:raise_server_errors).and_return(false)
      end

      it "shows an error message" do
        within "#notifications" do
          click_on "Test button"
          expect(page).to have_content("There was a problem updating the notification")
        end
      end
    end
  end
end
