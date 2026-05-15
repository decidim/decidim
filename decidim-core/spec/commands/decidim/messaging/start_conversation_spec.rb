# frozen_string_literal: true

require "spec_helper"

module Decidim::Messaging
  describe StartConversation do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:another_user) { create(:user, :confirmed, organization:) }
    let!(:command) { described_class.new(form) }
    let(:sender) { user }
    let(:interlocutor) { another_user }
    let(:current_user) { user }
    let(:context) do
      {
        current_user:,
        sender:
      }
    end
    let(:form) do
      ConversationForm.from_params(params).with_context(context)
    end

    context "when the form is invalid" do
      let(:params) do
        {
          body: "",
          recipient_id: interlocutor.id
        }
      end

      it "does not create a conversation" do
        expect { command.call }.not_to change(Conversation, :count)
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

    shared_examples "a valid conversation" do |num_recipients, num_emails|
      let(:body) { "<3 from Patagonia" }
      let(:params) do
        {
          body:,
          recipient_id: interlocutor.id
        }
      end

      it "creates a conversation with one message" do
        expect { command.call }
          .to change(Conversation, :count)
          .by(1)
          .and change(Message, :count)
          .by(1)
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok, an_instance_of(Conversation))
      end

      it "sends a notification to #{num_recipients} recipients" do
        expect do
          perform_enqueued_jobs { command.call }
        end.to change(emails, :count).by(num_emails)
      end
    end

    context "when the sender and interlocutor are users" do
      context "and current_user exists" do
        it_behaves_like "a valid conversation", 1, 1
      end

      context "and current_user is nil" do
        let(:current_user) { nil }

        it_behaves_like "a valid conversation", 1, 1
      end
    end

    context "when the body has just the right length without carriage returns" do
      before do
        allow(Decidim.config).to receive(
          :maximum_conversation_message_length
        ).and_return(80)
      end

      it_behaves_like "a valid conversation", 1, 1 do
        let(:body) { "This text is just the correct length\r\nwith the carriage return characters removed" }
      end
    end
  end
end
