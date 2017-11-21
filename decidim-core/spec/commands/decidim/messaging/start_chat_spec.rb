# frozen_string_literal: true

require "spec_helper"

module Decidim::Messaging
  describe StartChat do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let!(:command) { described_class.new(form) }
    let(:interlocutor) { create(:user) }

    context "when the form is invalid" do
      let(:form) do
        ChatForm.from_params(body: "", recipient_id: interlocutor.id)
      end

      it "does not create a chat" do
        expect { command.call }.not_to change { Chat.count }
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
        ChatForm.from_params(
          body: "<3 from Patagonia",
          recipient_id: interlocutor.id
        ).with_context(current_user: user)
      end

      it "creates a chat with one message" do
        expect { command.call }
          .to change { Chat.count }
          .by(1)
          .and change { Message.count }
          .by(1)
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok, an_instance_of(Chat))
      end

      it "sends a notification to the recipient" do
        expect do
          perform_enqueued_jobs { command.call }
        end.to change { emails.count }.by(1)
      end
    end
  end
end
