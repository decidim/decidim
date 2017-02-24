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

      describe "#reported_by?" do
        let(:user) { create(:user, organization: subject.organization) }

        it "returns false if the proposal has not been reported by the given user" do
          expect(subject.reported_by?(user)).to be_falsey
        end

        it "returns true if the proposal has been reported by the given user" do
          create(:proposal_report, proposal: subject, user: user)
          expect(subject.reported_by?(user)).to be_truthy
        end
      end

      context "#hidden?" do
        it "returns false if the proposal hidden_at attribute is nil" do
          expect(subject).not_to be_hidden
        end

        it "returns true if the proposal is not voted by the given user" do
          subject.hidden_at = Time.current
          expect(subject).to be_hidden
        end
      end

      context "#reported?" do
        it "returns false if the proposal report count is equal to 0" do
          expect(subject).not_to be_reported
        end

        it "returns true if the proposal report count is greater than 0" do
          subject.report_count = 1
          expect(subject).to be_reported
        end
      end

      context "when it has been accepted" do
        let(:proposal) { build(:proposal, :accepted) }

        it { is_expected.to be_answered }
        it { is_expected.to be_accepted }
      end

      context "when it has been rejected" do
        let(:proposal) { build(:proposal, :rejected) }

        it { is_expected.to be_answered }
        it { is_expected.to be_rejected }
      end
    end
  end
end
