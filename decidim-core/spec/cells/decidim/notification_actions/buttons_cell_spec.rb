# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationActions::ButtonsCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController
  let!(:organization) { create(:organization) }
  let(:data) do
    [
      {
        label: "Accept",
        url: "/accept"
      },
      {
        label: "Reject",
        url: "/reject"
      }
    ]
  end
  let(:user) { create(:user, :confirmed, organization:) }
  let(:my_cell) { cell("decidim/notification_actions/buttons", notification) }
  let(:notification) { create(:notification, user:, resource:) }
  let(:component) { create(:component, manifest_name: "dummy", organization:) }
  let(:resource) { create(:dummy_resource, component:) }
  let(:action_cell) { "decidim/notification_actions/buttons" }

  before do
    allow(notification.event_class_instance).to receive(:action_cell).and_return(action_cell)
    allow(notification.event_class_instance).to receive(:action_data).and_return(data)
  end

  it "has data associated" do
    expect(my_cell.data).to eq(data)
    expect(my_cell.action_cell).to eq(action_cell)
  end

  it "renders the buttons" do
    expect(subject).to have_link(count: 2)
    expect(subject).to have_link(text: "Accept", href: "/accept", class: "button button__sm button__transparent-secondary")
    expect(subject).to have_link(text: "Reject", href: "/reject", class: "button button__sm button__transparent-secondary")
    expect(subject).to have_css("[data-notification-action=button]")
    expect(subject).to have_no_css("[data-method]")
    expect(subject).to have_no_css("svg")
  end

  context "when no data" do
    let(:data) { "" }

    it "does not render the callout" do
      expect(subject.text).to be_blank
    end
  end

  context "when additional data is present" do
    let(:data) do
      [
        {
          label: "Accept",
          url: "/accept",
          icon: "coin-line",
          method: "post",
          class: "button__primary"
        }
      ]
    end

    it "renders the callout" do
      expect(subject).to have_link(count: 1)
      expect(subject).to have_link(text: "Accept", href: "/accept", class: "button button__sm button__primary")
      expect(subject).to have_css("[data-notification-action=button]")
      expect(subject).to have_css("[data-method=post]")
      expect(subject).to have_xpath("//svg/use[contains(@href, 'ri-coin-line')]")
    end
  end

  context "when using i18n_label" do
    let(:data) do
      [
        {
          i18n_label: "decidim.menu.home",
          url: "/home"
        }
      ]
    end

    it "renders the button" do
      expect(subject).to have_link(text: "Home", href: "/home", class: "button button__sm button__transparent-secondary")
    end
  end
end
