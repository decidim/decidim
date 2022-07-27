# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataConversationSerializer do
    subject { described_class.new(conversation) }

    let(:organization) { create(:organization) }
    let(:user) { create :user, :confirmed, organization: }

    let(:conversation) do
      Messaging::Conversation.start!(
        originator: user,
        interlocutors: [create(:user)],
        body: "Hi!"
      )
    end

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: conversation.id)
      end

      it "includes the messages" do
        expect(serialized[:messages].length).to eq(1)
        expect(serialized[:messages].first).to include(message_id: conversation.messages.first.id)
        expect(serialized[:messages].first).to include(sender_id: conversation.messages.first.sender.id)
        expect(serialized[:messages].first).to include(sender_name: conversation.messages.first.sender.name)
        expect(serialized[:messages].first).to include(body: conversation.messages.first.body)
        expect(serialized[:messages].first).to include(created_at: conversation.messages.first.created_at)
        expect(serialized[:messages].first).to include(updated_at: conversation.messages.first.updated_at)
      end

      it "includes the created at" do
        expect(serialized).to include(created_at: conversation.created_at)
      end

      it "includes the updated at" do
        expect(serialized).to include(updated_at: conversation.updated_at)
      end
    end
  end
end
