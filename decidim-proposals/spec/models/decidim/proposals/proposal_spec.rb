# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe Proposal do
      subject { create(:proposal) }

      it { is_expected.to be_valid }

      it "has a votes association returning proposal votes" do
        expect(subject.votes.count).to eq(0)
      end
      
      context "when the category is from another feature" do
        subject { build(:proposal, category: create(:category))}

        it { is_expected.to be_invalid}
      end

      context "when the author is from another organization" do
        subject { build(:proposal, author: create(:user))}

        it { is_expected.to be_invalid}
      end

      context "when the scope is from another organization" do
        subject { build(:proposal, scope: create(:scope))}

        it { is_expected.to be_invalid}
      end

      describe "#voted_by?" do
        let(:user) { create(:user, organization: subject.organization) }

        it "should return false if the proposal is not voted by the given user" do
          expect(subject.voted_by?(user)).to be_falsey
        end

        it "should return true if the proposal is not voted by the given user" do
          create(:proposal_vote, proposal: subject, author: user)
          expect(subject.voted_by?(user)).to be_truthy
        end
      end
    end
  end
end
