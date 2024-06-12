# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationActions::CalloutCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:my_cell) { cell("decidim/notification_actions/callout", notification) }
  let(:notification) { create(:notification, user:, resource:, extra:) }
  let(:component) { create(:component, manifest_name: "dummy", organization:) }
  let(:resource) { create(:dummy_resource, component:) }
  let(:extra) do
    { action: }
  end
  let(:action) do
    {
      "data" => data,
      "type" => "callout",
      "class" => "success"
    }
  end
  let(:data) { "A great message for the actions" }

  it "has a data associated" do
    expect(my_cell.data).to eq(data)
    expect(my_cell.action).to eq(action)
    expect(my_cell.classes).to eq("callout success")
  end

  it "renders the callout" do
    expect(subject).to have_content(data)
    expect(subject.text).to eq(data)
    expect(subject).to have_css(".callout.success")
  end

  context "when a different class" do
    let(:action) do
      {
        "data" => "another data",
        "type" => "callout",
        "class" => "warning"
      }
    end

    it "renders the callout" do
      expect(my_cell.classes).to eq("callout warning")
      expect(subject).to have_content("another data")
      expect(subject).to have_css(".callout.warning")
    end
  end

  context "when no data" do
    let(:data) { "" }

    it "does not render the callout" do
      expect(subject.text).to be_blank
    end
  end
end
