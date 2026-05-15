# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::Conversation do
  describe ".start_conversation" do
    let(:originator) { create(:user) }
    let(:interlocutor) { create(:user) }
    let(:from) { nil }
    let(:conversation) do
      described_class.start!(
        originator:,
        interlocutors: [interlocutor],
        body: "Hei!",
        user: from
      )
    end

    let(:receipts) { conversation.receipts }

    context "when there are more than 2 participants" do
      let(:conversation) do
        described_class.start!(
          originator:,
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
  end
end
