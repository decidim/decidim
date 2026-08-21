# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::ConversationBetween do
  subject(:query) { described_class.new(users) }

  let(:organization) { create(:organization) }
  let!(:user1) { create(:user, :confirmed, organization:) }
  let!(:user2) { create(:user, :confirmed, organization:) }
  let!(:user3) { create(:user, :confirmed, organization:) }
  let!(:user4) { create(:user, :confirmed, organization:) }
  let!(:conversation_between_u1_u2) { create(:conversation, originator: user1, interlocutors: [user2]) }
  let!(:conversation_between_u1_u2_u3) { create(:conversation, originator: user1, interlocutors: [user2, user3]) }
  let!(:conversation_between_u2_u1_u3_u4) { create(:conversation, originator: user2, interlocutors: [user1, user3, user4]) }

  shared_examples "working conversations between query" do
    context "with user1 and user2" do
      let(:users) { [user1, user2] }

      it "finds the correct conversations for all combinations" do
        expect(subject).to eq(conversation_between_u1_u2)
      end
    end

    context "with user2 and user1" do
      let(:users) { [user2, user1] }

      it "finds the correct conversations for all combinations" do
        expect(subject).to eq(conversation_between_u1_u2)
      end
    end

    context "with user1, user2 and user3" do
      let(:users) { [user1, user2, user3].shuffle }

      it "finds the correct conversations for all combinations" do
        expect(subject).to eq(conversation_between_u1_u2_u3)
      end
    end

    context "with user1, user2, user3 and user4" do
      let(:users) { [user1, user2, user3, user4].shuffle }

      it "finds the correct conversations for all combinations" do
        expect(subject).to eq(conversation_between_u2_u1_u3_u4)
      end
    end
  end

  describe "#query" do
    subject(:result) { query.query }

    it_behaves_like "working conversations between query" do
      subject { result.first }
    end

    context "with user1 and user2" do
      let(:users) { [user1, user2] }

      it "finds the correct amount of conversations" do
        expect(result.count).to eq(1)
      end
    end

    context "with user1, user2 and user3" do
      let(:users) { [user1, user2, user3].shuffle }

      it "finds the correct amount of conversations" do
        expect(result.count).to eq(1)
      end
    end

    context "with user1, user2, user3 and user4" do
      let(:users) { [user1, user2, user3, user4].shuffle }

      it "finds the correct amount of conversations" do
        expect(result.count).to eq(1)
      end
    end
  end

  describe "#find" do
    subject { query.find }

    it_behaves_like "working conversations between query"
  end
end
