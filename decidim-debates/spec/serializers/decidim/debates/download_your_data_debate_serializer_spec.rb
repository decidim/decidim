# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Debates::DownloadYourDataDebateSerializer do
    subject { described_class.new(resource) }
    let(:resource) { create(:debate) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the title" do
        expect(serialized).to include(title: resource.title)
      end

      it "includes the description" do
        expect(serialized).to include(description: resource.description)
      end

      it "includes the instructions" do
        expect(serialized).to include(instructions: resource.instructions)
      end

      it "includes the start time" do
        expect(serialized).to include(start_time: resource.start_time)
      end

      it "includes the end time" do
        expect(serialized).to include(end_time: resource.end_time)
      end

      it "includes the information updates" do
        expect(serialized).to include(information_updates: resource.information_updates)
      end

      it "includes the reference" do
        expect(serialized).to include(reference: resource.reference)
      end

      it "includes the component" do
        expect(serialized).to include(component: resource.component.name)
      end
    end
  end
end
