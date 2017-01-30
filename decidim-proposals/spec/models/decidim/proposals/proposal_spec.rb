# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe Proposal do
      let(:proposal) { build(:proposal) }
      subject { proposal }

      include_examples "authorable"
      include_examples "has feature"
      include_examples "has scope"
      include_examples "has category"

      it { is_expected.to be_valid }

      it "has a votes association returning proposal votes" do
        expect(subject.votes.count).to eq(0)
      end

      describe "#voted_by?" do
        let(:user) { create(:user, organization: subject.organization) }

        it "returns false if the proposal is not voted by the given user" do
          expect(subject.voted_by?(user)).to be_falsey
        end

        it "returns true if the proposal is not voted by the given user" do
          create(:proposal_vote, proposal: subject, author: user)
          expect(subject.voted_by?(user)).to be_truthy
        end
      end
    end
  end
end
