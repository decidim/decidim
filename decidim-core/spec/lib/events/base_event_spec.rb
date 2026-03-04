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
            machine_translations: {
              es: "Spanish - My string"
            }
          }
        end

        it "returns the current locale string" do
          expect(subject.safe_resource_text).to eq "My string"
        end
      end

      describe "when the resource_text contains a relative image URL" do
        let(:organization) { build(:organization, host: "example.org") }
        let(:resource_text) { '<p><img src="/uploads/image.jpg"></p>' }

        before do
          allow(resource).to receive(:organization).and_return(organization)
        end

        it "prepends the organization root URL" do
          root_url = Decidim::EngineRouter.new("decidim", {}).root_url(host: organization.host)[0..-2]
          expect(subject.safe_resource_text).to eq %(<p><img src="#{root_url}/uploads/image.jpg"></p>)
        end
      end

      describe "when the resource_text contains an absolute image URL" do
        let(:organization) { build(:organization, host: "example.org") }
        let(:resource_text) { '<p><img src="https://cdn.example.org/image.jpg"></p>' }

        before do
          allow(resource).to receive(:organization).and_return(organization)
        end

        it "keeps the URL unchanged" do
          expect(subject.safe_resource_text).to eq resource_text
        end
      end
    end
  end
end
