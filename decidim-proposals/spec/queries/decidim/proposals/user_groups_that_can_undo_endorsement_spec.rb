# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UserGroupsThatCanUndoEndorsement do
      let(:proposal) { create(:proposal) }
      let(:current_user) { create(:user, organization: proposal.organization) }
      let(:command) { described_class.new(proposal, current_user) }
      let(:params) do
        {
          proposal_id: proposal.id,
          feature_id: feature.id,
          participatory_process_slug: feature.participatory_space.slug
        }
      end

      describe "when user has no user_groups" do
        it { expect { UserGroupsThatCanUndoEndorsement.from(current_user, proposal).to be_empty } }
      end

      describe "when user belongs to user_groups" do
        let(:user_groups) do
          [create(:user_group, verified_at: DateTime.current),
           create(:user_group, verified_at: DateTime.current)]
        end

        before do
          user_groups.each do |ug|
            create(:user_group_membership, user: current_user, user_group: ug)
          end
          current_user.reload
        end
        context "when user's user_groups are not verified" do
          it "ignores them" do
            user_groups.each { |ug| ug.update_attributes verified_at: nil }

            expect { UserGroupsThatCanUndoEndorsement.from(current_user, proposal).to be_empty }
          end
        end
        context "when all user user_groups are endorsed" do
          before do
            user_groups.each do |ug|
              create(:proposal_endorsement,
                     proposal: proposal, author: current_user, decidim_user_group_id: ug.id)
            end
          end
          it "returns all user_groups to undo current endorsements" do
            expected_unendorsable_groups = user_groups.collect(&:id)
            expect(UserGroupsThatCanUndoEndorsement.from(current_user, proposal)).to eq expected_unendorsable_groups
          end
        end
        context "when half of user user_groups are endorsed" do
          it "returns the other half of user's user_groups" do
            create(:proposal_endorsement, proposal: proposal,
                                          author: current_user, decidim_user_group_id: user_groups.first.id)

            expected_unendorsable_groups = [user_groups.first.id]
            expect(UserGroupsThatCanUndoEndorsement.from(current_user, proposal)).to eq expected_unendorsable_groups
          end
        end
        context "when none of user's user_groups are endorsed" do
          it { expect { UserGroupsThatCanUndoEndorsement.from(current_user, proposal).to be_empty } }
        end
      end
    end
  end
end
