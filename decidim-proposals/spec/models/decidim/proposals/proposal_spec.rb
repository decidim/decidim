# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe Proposal do
      subject { proposal }

      let(:component) { build :proposal_component }
      let(:organization) { component.participatory_space.organization }
      let(:proposal) { build(:proposal, component: component) }
      let(:coauthorable) { proposal }

      include_examples "coauthorable"
      include_examples "has component"
      include_examples "has scope"
      include_examples "has category"
      include_examples "has reference"
      include_examples "reportable"

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      it "has a votes association returning proposal votes" do
        expect(subject.votes.count).to eq(0)
      end

      describe "#voted_by?" do
        let(:user) { create(:user, organization: subject.organization) }

        it "returns false if the proposal is not voted by the given user" do
          expect(subject).not_to be_voted_by(user)
        end

        it "returns true if the proposal is not voted by the given user" do
          create(:proposal_vote, proposal: subject, author: user)
          expect(subject).to be_voted_by(user)
        end
      end

      describe "#endorsed_by?" do
        let(:user) { create(:user, organization: subject.organization) }

        context "with User endorsement" do
          it "returns false if the proposal is not endorsed by the given user" do
            expect(subject).not_to be_endorsed_by(user)
          end

          it "returns true if the proposal is not endorsed by the given user" do
            create(:proposal_endorsement, proposal: subject, author: user)
            expect(subject).to be_endorsed_by(user)
          end
        end

        context "with Organization endorsement" do
          let!(:user_group) { create(:user_group, verified_at: Time.current, organization: user.organization) }
          let!(:membership) { create(:user_group_membership, user: user, user_group: user_group) }

          before { user_group.reload }

          it "returns false if the proposal is not endorsed by the given organization" do
            expect(subject).not_to be_endorsed_by(user, user_group)
          end

          it "returns true if the proposal is not endorsed by the given organization" do
            create(:proposal_endorsement, proposal: subject, author: user, user_group: user_group)
            expect(subject).to be_endorsed_by(user, user_group)
          end
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
        let(:participatory_space) { subject.component.participatory_space }
        let(:organization) { participatory_space.organization }
        let!(:participatory_process_admin) do
          create(:process_admin, participatory_process: participatory_space)
        end

        context "when the proposal is official" do
          let(:proposal) { build(:proposal, :official) }

          it "returns the followers and the component's participatory space admins" do
            expect(subject.users_to_notify_on_comment_created).to match_array(followers.concat([participatory_process_admin]))
          end
        end

        context "when the proposal is not official" do
          it "returns the followers" do
            expect(subject.users_to_notify_on_comment_created).to match_array(followers)
          end
        end
      end

      describe "#maximum_votes" do
        let(:maximum_votes) { 10 }

        context "when the component's settings are set to an integer bigger than 0" do
          before do
            component[:settings]["global"] = { threshold_per_proposal: 10 }
            component.save!
          end

          it "returns the maximum amount of votes for this proposal" do
            expect(proposal.maximum_votes).to eq(10)
          end
        end

        context "when the component's settings are set to 0" do
          before do
            component[:settings]["global"] = { threshold_per_proposal: 0 }
            component.save!
          end

          it "returns nil" do
            expect(proposal.maximum_votes).to be_nil
          end
        end
      end

      describe "#editable_by?" do
        let(:author) { build(:user, organization: organization) }

        context "when user is author" do
          let(:proposal) { build :proposal, component: component, users: [author], updated_at: Time.current }

          it { is_expected.to be_editable_by(author) }

          context "when the proposal has been linked to another one" do
            let(:proposal) { create :proposal, component: component, users: [author], updated_at: Time.current }
            let(:original_proposal) do
              original_component = create(:proposal_component, organization: organization, participatory_space: component.participatory_space)
              create(:proposal, component: original_component)
            end

            before do
              proposal.link_resources([original_proposal], "copied_from_component")
            end

            it { is_expected.not_to be_editable_by(author) }
          end
        end

        context "when proposal is from user group and user is admin" do
          let(:user_group) { create :user_group, :verified, users: [author], organization: author.organization }
          let(:proposal) { build :proposal, component: component, updated_at: Time.current, users: [author], user_groups: [user_group] }

          it { is_expected.to be_editable_by(author) }
        end

        context "when user is not the author" do
          let(:proposal) { build :proposal, component: component, updated_at: Time.current }

          it { is_expected.not_to be_editable_by(author) }
        end

        context "when proposal is answered" do
          let(:proposal) { build :proposal, :with_answer, component: component, updated_at: Time.current, users: [author] }

          it { is_expected.not_to be_editable_by(author) }
        end

        context "when proposal editing time has run out" do
          let(:proposal) { build :proposal, updated_at: 10.minutes.ago, component: component, users: [author] }

          it { is_expected.not_to be_editable_by(author) }
        end
      end

      describe "#withdrawn?" do
        context "when proposal is withdrawn" do
          let(:proposal) { build :proposal, :withdrawn }

          it { is_expected.to be_withdrawn }
        end

        context "when proposal is not withdrawn" do
          let(:proposal) { build :proposal }

          it { is_expected.not_to be_withdrawn }
        end
      end

      describe "#withdrawable_by" do
        let(:author) { build(:user, organization: organization) }

        context "when user is author" do
          let(:proposal) { build :proposal, component: component, users: [author], created_at: Time.current }

          it { is_expected.to be_withdrawable_by(author) }
        end

        context "when user is admin" do
          let(:admin) { build(:user, :admin, organization: organization) }
          let(:proposal) { build :proposal, component: component, users: [author], created_at: Time.current }

          it { is_expected.not_to be_withdrawable_by(admin) }
        end

        context "when user is not the author" do
          let(:someone_else) { build(:user, organization: organization) }
          let(:proposal) { build :proposal, component: component, users: [author], created_at: Time.current }

          it { is_expected.not_to be_withdrawable_by(someone_else) }
        end

        context "when proposal is already withdrawn" do
          let(:proposal) { build :proposal, :withdrawn, component: component, users: [author], created_at: Time.current }

          it { is_expected.not_to be_withdrawable_by(author) }
        end

        context "when the proposal has been linked to another one" do
          let(:proposal) { create :proposal, component: component, users: [author], created_at: Time.current }
          let(:original_proposal) do
            original_component = create(:proposal_component, organization: organization, participatory_space: component.participatory_space)
            create(:proposal, component: original_component)
          end

          before do
            proposal.link_resources([original_proposal], "copied_from_component")
          end

          it { is_expected.not_to be_withdrawable_by(author) }
        end
      end
    end
  end
end
