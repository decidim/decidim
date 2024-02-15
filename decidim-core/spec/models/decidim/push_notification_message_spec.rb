# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PushNotificationMessage do
    subject { push_notification_message }

    let(:action) { "new_message" }
    let(:organization) { build(:organization) }
    let(:sender) { build(:user, organization:, name: "John Doe") }
    let(:group) { build(:user_group, organization:, nickname: "acme") }
    let(:conversation) { create(:conversation) }
    let(:push_notification_message) { build(:push_notification_message, sender:, third_party: group, conversation:, action:) }

    actions = %w(
      comanagers_new_conversation
      comanagers_new_message
      new_conversation
      new_group_conversation
      new_group_message
      new_message
    )

    describe "validations" do
      context "without a valid action" do
        let(:action) { "invalid_action" }

        it "raises an error" do
          expect { subject }.to raise_error(Decidim::PushNotificationMessage::InvalidActionError)
        end
      end

      context "with a valid action" do
        actions.each do |action|
          it "does not raise an error on `#{action}` action" do
            subject = build(:push_notification_message, action:)
            expect { subject }.not_to raise_error
          end
        end
      end
    end

    describe "url" do
      it "returns the conversation url" do
        expect(subject.url).to eq("/conversations/#{conversation.id}")
      end
    end
  end
end
