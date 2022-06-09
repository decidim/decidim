# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::Serializer do
    subject { described_class.new(resource) }
    let(:resource) { OpenStruct.new(id: 1, name: "John") }

    describe "#serialize" do
      it "turns the object into a hash" do
        expect(subject.serialize).to eq(id: 1, name: "John")
      end
    end

    describe "#event_name" do
      it "turns class name into an event name" do
        expect(subject.event_name).to eq("decidim.serialize.exporters.serializer")
      end
    end

    context "when subscribed to the serialize event" do
      ActiveSupport::Notifications.subscribe("decidim.serialize.exporters.serializer") do |_event_name, data|
        data[:serialized_data][:johnny_boy] = "Get up Johnny boy because we all need you now"
      end

      it "includes new field" do
        expect(subject.run).to eq(resource.to_h.merge({ johnny_boy: "Get up Johnny boy because we all need you now" }))
      end
    end
  end
end
