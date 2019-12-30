# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::BaseEvent do
    subject do
      described_class.new(
        resource: resource,
        event_name: "some.event",
        user: user,
        extra: {}
      )
    end

    let(:user) { build(:user) }

    describe ".types" do
      subject { described_class }

      it "returns an empty array" do
        expect(subject.types).to eq []
      end
    end

    context "when the resource is hashtaggable" do
      let(:resource) { build(:dummy_resource) }

      before do
        title = "Proposal with #myhashtag"
        parsed_title = Decidim::ContentProcessor.parse(title, current_organization: resource.organization)
        resource.title = parsed_title.rewrite
      end

      it "returns the text correctly" do
        expect(subject.resource_title).not_to include("gid://")
        expect(subject.resource_title).to include("#myhashtag")
      end
    end
  end
end
