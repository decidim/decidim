# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:my_cell) { cell("decidim/notification", notification) }
  let(:notification) { create(:notification, user:, resource:) }
  let(:component) { create(:component, manifest_name: "dummy", organization:) }
  let(:resource) { create(:dummy_resource, component:) }

  it "has not action cell associated" do
    expect(my_cell.action_class).to be_nil
    expect(my_cell.action_cell).to be_nil
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

  describe "#action_cell" do
    before do
      allow(notification.event_class_instance).to receive(:action_cell).and_return(action_cell)
      allow(notification.event_class_instance).to receive(:action_data).and_return([{ url: "http://example.com", label: "Some label" }])
    end

    context "when action cell exists" do
      let(:action_cell) { "decidim/notification_actions/buttons" }

      it "is present" do
        expect(my_cell.action_class).to eq("Decidim::NotificationActions::ButtonsCell")
        expect(my_cell.action_cell).to eq("decidim/notification_actions/buttons")
      end
    end

    context "when action cell does not exist" do
      let(:action_cell) { "not_existing" }

      it "is not present" do
        expect(my_cell.action_cell).to be_nil
      end
    end
  end
end
