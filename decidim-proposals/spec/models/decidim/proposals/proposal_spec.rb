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

      describe "#users_to_notify_on_comment_created" do
        let!(:follows) { create_list(:follow, 3, followable: subject) }
        let(:followers) { follows.map(&:user) }
        let(:participatory_space) { subject.feature.participatory_space }
        let(:organization) { participatory_space.organization }
        let!(:participatory_process_admin) do
          user = create(:user, :confirmed, organization: organization)
          Decidim::ParticipatoryProcessUserRole.create!(
            role: :admin,
            user: user,
            participatory_process: participatory_space
          )
          user
        end

        context "when the proposal is official" do
          let(:proposal) { build(:proposal, :official) }

          it "returns the followers and the feature's participatory space admins" do
            expect(subject.users_to_notify_on_comment_created).to match_array(followers.concat([participatory_process_admin]))
          end
        end

        context "when the proposal is not official" do
          it "returns the followers" do
            expect(subject.users_to_notify_on_comment_created).to match_array(followers)
          end
        end
      end
    end
  end
end
