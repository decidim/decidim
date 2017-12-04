# frozen_string_literal: true

require "spec_helper"

module Decidim::Messaging
  describe StartConversation do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let!(:command) { described_class.new(form) }
    let(:interlocutor) { create(:user) }

    context "when the form is invalid" do
      let(:form) do
        ConversationForm.from_params(body: "", recipient_id: interlocutor.id)
      end

      it "does not create a conversation" do
        expect { command.call }.not_to change { Conversation.count }
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "does not send notifications" do
        expect do
          perform_enqueued_jobs { command.call }
        end.not_to change { emails.count }
      end
    end

    context "when the form is valid" do
      let(:form) do
        ConversationForm.from_params(
          body: "<3 from Patagonia",
          recipient_id: interlocutor.id
        ).with_context(current_user: user)
      end

      it "creates a conversation with one message" do
        expect { command.call }
          .to change { Conversation.count }
          .by(1)
          .and change { Message.count }
          .by(1)
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok, an_instance_of(Conversation))
      end

      it "sends a notification to the recipient" do
        expect do
          perform_enqueued_jobs { command.call }
        end.to change { emails.count }.by(1)
      end
    end
  end
end
