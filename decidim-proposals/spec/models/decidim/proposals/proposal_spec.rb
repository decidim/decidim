# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe Proposal do
      let(:comments_notifications) { true }
      let(:proposal) { build(:proposal) }
      subject { proposal }

      include_examples "authorable"
      include_examples "has feature"
      include_examples "has scope"
      include_examples "has category"
      include_examples "has reference"
      include_examples "reportable"

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

      describe "#notifiable?" do
        let(:context_author) { create(:user, organization: subject.author.organization) }

        context "when the context author is the same as the proposal's author" do
          let(:context_author) { subject.author }

          it "is not notifiable" do
            expect(subject.notifiable?(author: context_author)).to be_falsy
          end
        end

        context "when the context author is not the same as the proposal's author" do
          context "when the comment's author has not comments notifications enabled" do
            before do
              expect(subject.author).to receive(:comments_notifications?).and_return(false)
            end

            it "is not notifiable" do
              expect(subject.notifiable?(author: context_author)).to be_falsy
            end
          end

          context "when the comment's author has comments notifications enabled" do
            before do
              expect(subject.author).to receive(:comments_notifications?).and_return(true)
            end

            it "is not notifiable" do
              expect(subject.notifiable?(author: context_author)).to be_truthy
            end
          end
        end

        context "when the proposal is official" do
          let!(:organization) { create :organization }
          let!(:admin) { create :user, :admin, organization: organization }
          let!(:participatory_process) { create :participatory_process, organization: organization }
          let!(:process_admin) { create :user, :process_admin, organization: organization, participatory_process: participatory_process }
          let!(:feature) { create :proposal_feature, featurable: participatory_process }
          let!(:context_author) { create(:user, organization: organization) }
          let!(:proposal) { build(:proposal, :official, feature: feature) }

          it "is notifiable" do
            expect(subject.notifiable?(author: context_author)).to be_truthy
          end

          it "notifies admins and process admins" do
            expect(subject.users_to_notify).to match_array([admin, process_admin])
          end
        end
      end
    end
  end
end
