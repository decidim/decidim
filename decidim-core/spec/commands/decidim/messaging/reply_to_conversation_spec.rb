# frozen_string_literal: true

require "spec_helper"

module Decidim::Messaging
  describe ReplyToConversation do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:sender) { user }
    let(:originator) { create(:user) }

    let(:conversation) do
      Conversation.start!(
        originator: originator,
        interlocutors: [user],
        body: "Initial message"
      )
    end
    let(:context) do
      {
        sender: sender
      }
    end
    let(:form) do
      MessageForm.from_params(params).with_context(context)
    end

    let!(:command) { described_class.new(conversation, form) }

    context "when the form is invalid" do
      let(:params) do
        { body: "" }
      end

      it "does not create a message" do
        expect { command.call }.not_to change(Message, :count)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "does not send notifications" do
        expect do
          perform_enqueued_jobs { command.call }
        end.not_to change(emails, :count)
      end
    end

    context "when the form is valid" do
      let(:params) do
        { body: "<3 from Patagonia" }
      end

      it "creates a message with two receipts" do
        expect { command.call }
          .to change(Message, :count)
          .by(1)
          .and change(Receipt, :count)
          .by(2)
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok, an_instance_of(Message))
      end

      context "and the user didn't have unread messages in the conversation" do
        it "sends a notification to the recipient" do
          expect do
            perform_enqueued_jobs { command.call }
          end.to change(emails, :count).by(1)
        end
      end

      context "and the user already has unread messages in the conversation" do
        before do
          conversation.add_message!(sender: user, body: "Still thinking of you from Patagonia")
        end

        it "does not send notifications" do
          expect do
            perform_enqueued_jobs { command.call }
          end.not_to change(emails, :count)
        end
      end
    end
  end
end
