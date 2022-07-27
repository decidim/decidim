# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::EmailEvent do
    class TestEvent < Decidim::Events::BaseEvent
      include Events::EmailEvent
    end

    describe ".types" do
      subject { TestEvent }

      it "adds `:email` to the types array" do
        expect(subject.types).to include :email
      end
    end

    context "when the event behaves like email event" do
      subject do
        TestEvent.new(resource:, event_name: "test", user:)
      end

      let(:organization) { create(:organization, name: "O'Connor") }
      let(:user) { create(:user, name: "Sarah Connor", organization:) }
      let(:resource) { user }

      describe ".button_url" do
        it "responds and returns nil" do
          expect(subject.button_url).to be_nil
        end
      end

      describe ".button_text" do
        it "responds and returns nil" do
          expect(subject.button_text).to be_nil
        end
      end

      describe ".has_button?" do
        it "responds and returns false" do
          expect(subject).not_to have_button
        end
      end
    end
  end
end
