# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataNotificationSerializer do
    subject { described_class.new(resource) }
    let(:resource) { build(:notification) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the resource type" do
        expect(serialized[:resource_type]).to(
          include(id: resource.decidim_resource_id)
        )
        expect(serialized[:resource_type]).to(
          include(type: resource.decidim_resource_type)
        )
      end

      it "includes the event name" do
        expect(serialized).to include(event_name: resource.event_name)
      end

      it "includes the event class" do
        expect(serialized).to include(event_class: resource.event_class)
      end

      it "includes the created at" do
        expect(serialized).to include(created_at: resource.created_at)
      end

      it "includes the updated at" do
        expect(serialized).to include(updated_at: resource.updated_at)
      end

      it "includes the extra" do
        expect(serialized).to include(extra: resource.extra)
      end
    end
  end
end
