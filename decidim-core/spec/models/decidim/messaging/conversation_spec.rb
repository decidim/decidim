# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::Conversation do
  describe ".start_conversation" do
    let(:originator) { create(:user) }
    let(:interlocutor) { create(:user) }

    let(:conversation) do
      described_class.start!(
        originator: originator,
        interlocutors: [interlocutor],
        body: "Hei!"
      )
    end

    let(:receipts) { conversation.receipts }

    it "creates receipts for all participants" do
      expect(receipts.count).to eq(2)
    end

    it "creates a read receipt for sender" do
      sender_receipts = receipts.recipient(originator)

      expect(sender_receipts.size).to eq(1)
      expect(sender_receipts.first).not_to have_attributes(read_at: nil)
    end

    it "creates an unread receipt for interlocutor" do
      interlocutor_receipts = receipts.recipient(interlocutor)

      expect(interlocutor_receipts.size).to eq(1)
      expect(interlocutor_receipts.first).to have_attributes(read_at: nil)
    end
  end
end
