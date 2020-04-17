# frozen_string_literal: true

require "spec_helper"

module Decidim::Messaging
  describe StartConversation do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:another_user) { create(:user, organization: organization) }
    let(:user_group) { create(:user_group, :confirmed, organization: organization) }
    let(:another_user_group) { create(:user_group, :confirmed, organization: organization) }
    let!(:command) { described_class.new(form) }
    let(:sender) { user }
    let(:interlocutor) { another_user }
    let(:context) do
      {
        current_user: user,
        sender: sender
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

    shared_examples "a valid conversation" do
      let(:params) do
        {
          body: "<3 from Patagonia",
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

      it "sends a notification to the recipient" do
        expect do
          perform_enqueued_jobs { command.call }
        end.to change(emails, :count).by(1)
      end
    end

    context "when the sender and interlocutor are users" do
      it_behaves_like "a valid conversation"
    end

    context "when the interlocutor is a group and sender is a user" do
      let(:interlocutor) { user_group }

      it_behaves_like "a valid conversation"
    end

    context "when the interlocutor is an user and sender is a group" do
      let(:sender) { user_group }

      it_behaves_like "a valid conversation"
    end

    context "when the sender and interlocutor are groups" do
      let(:sender) { user_group }
      let(:interlocutor) { another_user_group }

      it_behaves_like "a valid conversation"
    end
  end
end
