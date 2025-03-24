# frozen_string_literal: true

require "spec_helper"

module Decidim::Messaging
  describe ReplyToConversation do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:another_user) { create(:user, :confirmed, organization:) }
    let(:sender) { user }
    let(:originator) { another_user }
    let(:current_user) { user }
    let(:context) do
      {
        current_user:,
        sender:
      }
    end

    let(:conversation) do
      Conversation.start!(
        originator:,
        interlocutors: [sender],
        body: "Initial message"
      )
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

    shared_examples "valid message with receipts" do |num_receipts|
      it "creates a message with #{num_receipts} receipts" do
        expect { command.call }
          .to change(Message, :count)
          .by(1)
          .and change(Receipt, :count)
          .by(num_receipts)
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok, an_instance_of(Message))
      end
    end

    shared_examples "send emails" do |num_emails|
      context "and the receiver did not have unread messages in the conversation" do
        it "sends a notification to the recipient" do
          expect do
            perform_enqueued_jobs { command.call }
          end.to change(emails, :count).by(num_emails)
        end
      end

      context "and the receiver already has unread messages in the conversation" do
        before do
          conversation.add_message!(sender:, body: "Still thinking of you from Patagonia")
        end

        it "does not send notifications" do
          expect do
            perform_enqueued_jobs { command.call }
          end.not_to change(emails, :count)
        end
      end
    end

    context "when the form is valid" do
      let(:body) { "<3 from Patagonia" }
      let(:params) do
        { body: }
      end

      it_behaves_like "valid message with receipts", 2
      it_behaves_like "send emails", 1

      context "and the body has just the right length without carriage returns" do
        let(:body) { "This text is just the correct length\r\nwith the carriage return characters removed" }

        before do
          allow(Decidim.config).to receive(
            :maximum_conversation_message_length
          ).and_return(80)
        end

        it_behaves_like "valid message with receipts", 2
      end
    end
  end
end
