# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ShowEndorsementIdentities do
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

      context "when user has no user_groups" do
        it "allows only an endorse button for the user" do
          expected_groups_split = { endorse: [], unendorse: [] }

          expect { command.call }.to broadcast :ok, expected_groups_split
        end
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
            expected_groups_split = { endorse: [], unendorse: [] }

            expect { command.call }.to broadcast :ok, expected_groups_split
          end
        end
        context "when all user user_groups are endorsed" do
          it "offers only user_groups to unahere" do
            user_groups.each do |ug|
              create(:proposal_endorsement,
                     proposal: proposal, author: current_user, decidim_user_group_id: ug.id)
            end
            expected_groups_split = { endorse: [], unendorse: user_groups.collect(&:id) }

            expect { command.call }.to broadcast :ok, expected_groups_split
          end
        end
        context "when half of user user_groups are endorsed" do
          it "offers the corresponding action to each user_groups" do
            create(:proposal_endorsement, proposal: proposal,
                                          author: current_user, decidim_user_group_id: user_groups.first.id)
            expected_groups_split = { endorse: [user_groups.last.id], unendorse: [user_groups.first.id] }

            expect { command.call }.to broadcast :ok, expected_groups_split
          end
        end
        context "when none of user's user_groups are endorsed" do
          it "offers all user_groups to endorse" do
            expected_groups_split = { endorse: user_groups.collect(&:id), unendorse: [] }

            expect { command.call }.to broadcast :ok, expected_groups_split
          end
        end
      end
    end
  end
end
