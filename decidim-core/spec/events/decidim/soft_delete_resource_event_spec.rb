# frozen_string_literal: true

require "spec_helper"

describe Decidim::SoftDeleteResourceEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.resources.soft_deleted" }
  let(:resource) { create(:dummy_resource, title: { en: "My super dummy resource" }) }
  let(:resource_type) { "Dummy resource" }
  let(:resource_title) { "My super dummy resource" }

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to include("An admin has deleted your \"#{resource_type}\" \"#{resource_title}\".")
    end
  end
end
