# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe Proposal do
      subject { proposal }

      let(:component) { build(:proposal_component) }
      let(:organization) { component.participatory_space.organization }
      let(:proposal) { create(:proposal, component:) }
      let(:coauthorable) { proposal }

      include_examples "coauthorable"
      include_examples "likeable"
      include_examples "has component"
      include_examples "has taxonomies"
      include_examples "has reference"
      include_examples "reportable"
      include_examples "resourceable"

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }
      it { is_expected.to act_as_paranoid }

      describe "newsletter participants" do
        subject { Decidim::Proposals::Proposal.newsletter_participant_ids(proposal.component) }

        let!(:component_out_of_newsletter) { create(:proposal_component, organization:) }
        let!(:resource_out_of_newsletter) { create(:proposal, component: component_out_of_newsletter) }
        let!(:resource_in_newsletter) { create(:proposal, component: proposal.component) }
        let(:author_ids) { proposal.notifiable_identities.pluck(:id) + resource_in_newsletter.notifiable_identities.pluck(:id) }

        include_examples "counts commentators as newsletter participants"
      end

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

      context "when it has been accepted" do
        let(:proposal) { build(:proposal, :accepted) }

        it { is_expected.to be_answered }
        it { is_expected.to be_published_state }
        it { is_expected.to be_accepted }
      end

      context "when it has been rejected" do
        let(:proposal) { build(:proposal, :rejected) }

        it { is_expected.to be_answered }
        it { is_expected.to be_published_state }
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
            expect(subject.users_to_notify_on_comment_created).to match_array(followers.push(participatory_process_admin))
          end
        end

        context "when the proposal is not official" do
          it "returns the followers and the author" do
            expect(subject.users_to_notify_on_comment_created).to match_array(followers.push(proposal.creator.author))
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
        let(:author) { create(:user, organization:) }

        context "when user is author" do
          let(:proposal) { create(:proposal, component:, users: [author], updated_at: Time.current) }

          it { is_expected.to be_editable_by(author) }

          context "when the proposal has been linked to another one" do
            let(:proposal) { create(:proposal, component:, users: [author], updated_at: Time.current) }
            let(:original_proposal) do
              original_component = create(:proposal_component, organization:, participatory_space: component.participatory_space)
              create(:proposal, component: original_component)
            end

            before do
              proposal.link_resources([original_proposal], "copied_from_component")
            end

            it { is_expected.not_to be_editable_by(author) }
          end
        end

        context "when user is not the author" do
          let(:proposal) { create(:proposal, component:, updated_at: Time.current) }

          it { is_expected.not_to be_editable_by(author) }
        end

        context "when proposal is answered" do
          let(:proposal) { build(:proposal, :with_answer, component:, updated_at: Time.current, users: [author]) }

          it { is_expected.not_to be_editable_by(author) }
        end

        context "when proposal editing time has run out" do
          let(:proposal) { build(:proposal, updated_at: 10.minutes.ago, component:, users: [author]) }

          it { is_expected.not_to be_editable_by(author) }
        end

        context "when proposal edit time is infinite" do
          before do
            component[:settings]["global"] = { proposal_edit_time: "infinite" }
            component.save!
          end

          let(:proposal) { build(:proposal, updated_at: 10.years.ago, component:, users: [author]) }

          it do
            proposal.add_coauthor(author)
            proposal.save!
            expect(proposal).to be_editable_by(author)
          end
        end
      end

      describe "#withdrawn?" do
        context "when proposal is withdrawn" do
          let(:proposal) { build(:proposal, :withdrawn) }

          it { is_expected.to be_withdrawn }
        end

        context "when proposal is not withdrawn" do
          let(:proposal) { build(:proposal) }

          it { is_expected.not_to be_withdrawn }
        end
      end

      describe "#withdrawable_by" do
        let(:author) { create(:user, organization:) }

        context "when user is author" do
          let(:proposal) { create(:proposal, component:, users: [author], created_at: Time.current) }

          it { is_expected.to be_withdrawable_by(author) }
        end

        context "when user is admin" do
          let(:admin) { build(:user, :admin, organization:) }
          let(:proposal) { build(:proposal, component:, users: [author], created_at: Time.current) }

          it { is_expected.not_to be_withdrawable_by(admin) }
        end

        context "when user is not the author" do
          let(:someone_else) { build(:user, organization:) }
          let(:proposal) { build(:proposal, component:, users: [author], created_at: Time.current) }

          it { is_expected.not_to be_withdrawable_by(someone_else) }
        end

        context "when proposal is already withdrawn" do
          let(:proposal) { build(:proposal, :withdrawn, component:, users: [author], created_at: Time.current) }

          it { is_expected.not_to be_withdrawable_by(author) }
        end

        context "when the proposal has been linked to another one" do
          let(:proposal) { create(:proposal, component:, users: [author], created_at: Time.current) }
          let(:original_proposal) do
            original_component = create(:proposal_component, organization:, participatory_space: component.participatory_space)
            create(:proposal, component: original_component)
          end

          before do
            proposal.link_resources([original_proposal], "copied_from_component")
          end

          it { is_expected.not_to be_withdrawable_by(author) }
        end
      end

      context "when answer is not published" do
        let(:proposal) { create(:proposal, :accepted_not_published, component:) }

        it "has accepted as the internal state" do
          expect(proposal.internal_state).to eq("accepted")
        end

        it "has not_answered as public state" do
          expect(proposal.state).to be_nil
        end

        it { is_expected.not_to be_accepted }
        it { is_expected.to be_answered }
        it { is_expected.not_to be_published_state }
      end

      describe "#with_evaluation_assigned_to" do
        let(:user) { create(:user, organization:) }
        let(:space) { component.participatory_space }
        let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process: space) }
        let(:assigned_proposal) { create(:proposal, component:) }
        let!(:assignment) { create(:evaluation_assignment, proposal: assigned_proposal, evaluator_role:) }

        it "only returns the assigned proposals for the given space" do
          results = described_class.with_evaluation_assigned_to(user, space)

          expect(results).to eq([assigned_proposal])
        end
      end

      describe "#coauthor_invitations_for" do
        let!(:notification) do
          create(:notification, :proposal_coauthor_invite, resource: proposal, user: coauthor)
        end
        let(:coauthor) { create(:user, organization:) }

        it "returns the coauthor invitations for the given user" do
          expect(proposal.coauthor_invitations_for(coauthor)).to eq([notification])
        end

        context "when the user has not been invited" do
          it "returns empty" do
            expect(proposal.coauthor_invitations_for(create(:user))).to be_empty
          end
        end

        context "when the user the notification is for another event" do
          let!(:notification) do
            create(:notification, event_class: "Decidim::Proposals::AnotherEvent", resource: proposal, user: coauthor)
          end

          it "returns empty" do
            expect(proposal.coauthor_invitations_for(coauthor)).to be_empty
          end
        end
      end

      describe "#actions_for_comment" do
        let(:proposal) { create(:proposal, component:) }
        let(:author) { create(:user, :confirmed, organization: component.organization) }
        let(:comment) { create(:comment, author:, commentable: proposal) }

        it "returns actions to invite the comment author as a co-author" do
          expect(proposal.actions_for_comment(comment, proposal.creator_author)).to eq([
                                                                                         {
                                                                                           label: "Mark as co-author",
                                                                                           url: EngineRouter.main_proxy(component).proposal_invite_coauthors_path(proposal_id: proposal.id, id: comment.author.id),
                                                                                           icon: "user-add-line",
                                                                                           method: :post,
                                                                                           data: {
                                                                                             confirm: "Are you sure you want to mark this user as a co-author? The receiver will receive a notification to accept or decline the invitation."
                                                                                           }
                                                                                         }
                                                                                       ])
        end

        context "when the requester user is not the author of the proposal" do
          it "returns nil" do
            expect(proposal.actions_for_comment(comment, create(:user))).to be_nil
          end
        end

        context "when no requester" do
          it "returns nil" do
            expect(proposal.actions_for_comment(comment, nil)).to be_nil
          end
        end

        context "when the author has already been invited" do
          let!(:notification) do
            create(:notification, :proposal_coauthor_invite, resource: proposal, user: comment.author)
          end

          it "returns actions to remove the co-author invitation" do
            expect(proposal.actions_for_comment(comment, proposal.creator_author)).to eq([
                                                                                           {
                                                                                             label: "Cancel co-author invitation",
                                                                                             url: EngineRouter.main_proxy(component).cancel_proposal_invite_coauthors_path(proposal_id: proposal.id, id: comment.author.id),
                                                                                             icon: "user-forbid-line",
                                                                                             method: :delete,
                                                                                             data: {
                                                                                               confirm: "Are you sure you want to cancel the co-author invitation?"
                                                                                             }
                                                                                           }
                                                                                         ])
          end

          context "when the requester user is not the author of the proposal" do
            it "returns nil" do
              expect(proposal.actions_for_comment(comment, create(:user))).to be_nil
            end
          end
        end
      end
    end
  end
end
