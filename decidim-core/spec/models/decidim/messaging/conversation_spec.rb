# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::Conversation do
  describe ".start_conversation" do
    let(:originator) { create(:user) }
    let(:interlocutor) { create(:user) }
    let(:from) { nil }
    let(:conversation) do
      described_class.start!(
        originator: originator,
        interlocutors: [interlocutor],
        body: "Hei!",
        user: from
      )
    end

    let(:receipts) { conversation.receipts }

    context "when there are more than 2 participants" do
      let(:conversation) do
        described_class.start!(
          originator: originator,
          interlocutors: [interlocutor, interlocutor2],
          body: "Hei!"
        )
      end
      let(:interlocutor2) { create(:user) }

      before do
        allow(interlocutor).to receive(:accepts_conversation?).and_return(true)
        allow(interlocutor2).to receive(:accepts_conversation?).and_return(true)
      end

      context "and some interlocutor does not accept the originator" do
        before do
          allow(interlocutor).to receive(:accepts_conversation?).and_return(false)
        end

        it "accept_user? returns false" do
          expect(conversation.accept_user?(originator)).to be(false)
        end
      end

      context "and all the interlocutor accept the originator" do
        it "accept_user? returns true" do
          expect(conversation.accept_user?(originator)).to be(true)
        end
      end

      context "and all the interlocutor have their accounts deleted" do
        before do
          allow(interlocutor).to receive(:deleted?).and_return(true)
          allow(interlocutor2).to receive(:deleted?).and_return(true)
        end

        it "with_deleted_users? returns true" do
          expect(conversation.with_deleted_users?(originator)).to be(true)
        end
      end

      context "and one of the interlocutor has the account deleted" do
        before do
          allow(interlocutor).to receive(:deleted?).and_return(true)
        end

        it "with_deleted_users? returns false" do
          expect(conversation.with_deleted_users?(originator)).to be(false)
        end
      end
    end

    context "when the originator is a group" do
      let(:originator) { create(:user_group, users: [manager1, manager2]) }
      let(:manager1) { create(:user) }
      let(:manager2) { create(:user) }
      let(:from) { manager1 }

      it "creates receipts for all participants" do
        expect(receipts.count).to eq(3)
      end

      it "creates a read receipt for the sender group manager" do
        manager_receipts = receipts.recipient(manager1)

        expect(manager_receipts.size).to eq(1)
        expect(manager_receipts.first).not_to have_attributes(read_at: nil)
      end

      it "creates an unread receipt for the group managers" do
        manager_receipts = receipts.recipient(manager2)

        expect(manager_receipts.size).to eq(1)
        expect(manager_receipts.first).to have_attributes(read_at: nil)
      end

      it "creates an unread receipt for the interlocutor" do
        interlocutor_receipts = receipts.recipient(interlocutor)

        expect(interlocutor_receipts.size).to eq(1)
        expect(interlocutor_receipts.first).to have_attributes(read_at: nil)
      end
    end

    context "when the interlocutor is a group" do
      let(:interlocutor) { create(:user_group, users: [manager1, manager2]) }
      let(:manager1) { create(:user) }
      let(:manager2) { create(:user) }
      let(:from) { manager1 }

      it "creates receipts for all participants" do
        expect(receipts.count).to eq(3)
      end

      it "creates an unread receipt for the first manager" do
        manager_receipts = receipts.recipient(manager1)

        expect(manager_receipts.size).to eq(1)
        expect(manager_receipts.first).to have_attributes(read_at: nil)
      end

      it "creates an unread receipt for the second manager" do
        manager_receipts = receipts.recipient(manager2)

        expect(manager_receipts.size).to eq(1)
        expect(manager_receipts.first).to have_attributes(read_at: nil)
      end

      it "creates a read receipt for originator" do
        originator_receipts = receipts.recipient(originator)

        expect(originator_receipts.size).to eq(1)
        expect(originator_receipts.first).not_to have_attributes(read_at: nil)
      end
    end
  end
end
