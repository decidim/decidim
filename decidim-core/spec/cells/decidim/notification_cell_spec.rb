# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController
  let!(:organization) { create :organization }
  let(:user) { create :user, :confirmed, organization: }
  let(:my_cell) { cell("decidim/notification", notification) }
  let(:notification) { create :notification, user:, resource: }
  let(:component) { create(:component, manifest_name: "dummy", organization:) }
  let(:resource) { create(:dummy_resource, component:) }

  context "when resource exists" do
    it "Resource title is present" do
      expect(my_cell.notification_title).to include("An event occured")
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
end
