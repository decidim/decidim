# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PushNotificationMessage do
    subject { push_notification_message }

    let(:organization) { build(:organization) }
    let(:conversation) { create(:conversation) }
    let(:push_notification_message) { build(:push_notification_message, recipient:, conversation:) }

    describe "url" do
      it "returns the conversation url" do
        expect(subject.url).to eq("/conversations/#{conversation.id}")
      end
    end
  end
end
