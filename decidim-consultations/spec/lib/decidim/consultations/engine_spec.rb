# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::Engine do
  describe "decidim_consultations.authorization_transfer" do
    include_context "authorization transfer"

    let(:consultation) { create(:consultation, organization: organization) }
    let(:question1) { create(:question, consultation: consultation) }
    let(:question2) { create(:question, consultation: consultation) }
    let(:question3) { create(:question, consultation: consultation) }
    let(:original_records) do
      {
        votes: [
          create(:vote, question: question1, response: create(:response, question: question1), author: original_user),
          create(:vote, question: question2, response: create(:response, question: question1), author: original_user),
          create(:vote, question: question3, response: create(:response, question: question1), author: original_user)
        ]
      }
    end
    let(:transferred_votes) { Decidim::Consultations::Vote.where(author: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_votes.count).to eq(3)
      expect(transfer.records.count).to eq(3)
      expect(transferred_resources).to eq(transferred_votes)
    end
  end
end
