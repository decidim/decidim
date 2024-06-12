# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:my_cell) { cell("decidim/notification", notification) }
  let(:notification) { create(:notification, user:, resource:, extra:) }
  let(:component) { create(:component, manifest_name: "dummy", organization:) }
  let(:resource) { create(:dummy_resource, component:) }
  let(:extra) do
    { action: }
  end
  let(:action) { nil }

  it "has not action associated" do
    expect(my_cell.action).to be_nil
    expect(my_cell.action_cell).to be_nil
  end

  context "when extra is nil" do
    let(:extra) { nil }

    it "has not action associated" do
      expect(my_cell.action).to be_nil
      expect(my_cell.action_cell).to be_nil
    end
  end

  context "when resource exists" do
    it "Resource title is present" do
      expect(my_cell.notification_title).to include("An event occurred")
    end
  end

  context "when resource is missing" do
    before do
      # rubocop:disable Rails/SkipsModelValidations:
      notification.update_attribute(:decidim_resource_type, "Decidim::ParticipatoryProcessStep")
      # rubocop:enable Rails/SkipsModelValidations:
    end

    it "Resource title is present" do
      expect(my_cell.notification_title).to include("this notification belongs to an item that is no longer available")
    end
  end

  context "when resource is moderated" do
    let!(:resource) { create(:dummy_resource, :moderated, component:) }

    it "does not render the resource" do
      expect(subject.to_s).to include("Content moderated")
    end
  end

  context "when action exist" do
    let(:action) do
      {
        "data" => data,
        "type" => "callout"
      }
    end
    let(:data) { "Some data" }

    it "Action is present" do
      expect(my_cell.action).to eq(action)
      expect(my_cell.action_cell).to eq("decidim/notification_actions/callout")
    end

    context "and cell does not exist" do
      let(:action) do
        {
          "data" => data,
          "type" => "non_existent"
        }
      end

      it "Action is present" do
        expect(my_cell.action).to eq(action)
        expect(my_cell.action_cell).to be_nil
      end
    end
  end
end
