# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::BaseEvent do
    subject do
      described_class.new(
        resource:,
        event_name: "some.event",
        user:,
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

    describe "safe_resource_text" do
      let(:resource) { build(:dummy_resource) }

      before do
        allow(subject).to receive(:resource_text).and_return(resource_text)
      end

      describe "when the resource_text is nil" do
        let(:resource_text) { nil }

        it "returns a string" do
          expect(subject.safe_resource_text).to eq ""
        end
      end

      describe "when the resource_text is a String" do
        let(:resource_text) { "foobar" }

        it "returns the string" do
          expect(subject.safe_resource_text).to eq resource_text
        end
      end

      describe "when the resource_text is a translation hash" do
        let(:resource_text) do
          {
            en: "My string",
            "machine_translations" => {
              "es" => "Spanish - My string"
            }
          }
        end

        it "returns the current locale string" do
          expect(subject.safe_resource_text).to eq "My string"
        end
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
