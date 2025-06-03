# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PushNotificationMessage do
    subject { push_notification_message }

    let!(:organization) { create(:organization, favicon:) }
    let(:conversation) { create(:conversation) }
    let(:recipient) { build(:user, organization:) }
    let(:favicon) { nil }
    let(:push_notification_message) { build(:push_notification_message, recipient:, conversation:) }

    describe "#body" do
      it "returns the message body" do
        expect(subject.body).to eq(decidim_escape_translated(subject.message))
      end
    end

    describe "#user" do
      it "returns the recipient" do
        expect(subject.user).to eq(subject.recipient)
      end
    end

    describe "#icon" do
      context "when there is not a a favicon" do
        let(:favicon) { nil }

        it "returns the organization's favicon" do
          expect(subject.icon).to be_nil
        end
      end

      context "when there is a favicon" do
        let(:favicon) { Decidim::Dev.test_file("icon.png", "image/png") }

        it "returns the organization's favicon" do
          expect(subject.icon).to start_with("http://")
        end
      end
    end

    describe "#url" do
      it "returns the conversation url" do
        expect(subject.url).to eq("/conversations/#{conversation.id}")
      end
    end
  end
end
