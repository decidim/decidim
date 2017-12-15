# frozen_string_literal: true

require 'spec_helper'

module Decidim
  module Proposals
    describe ShowAdhesionIdentities do
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
        it "should allow only an adhere button for the user" do
          expected_groups_split= {adhere: [], unadhere: []}

          expect { command.call }.to broadcast :ok, expected_groups_split
        end
      end
      describe "when user belongs to user_groups" do
        let(:user_groups) do
          [create(:user_group, verified_at: DateTime.now),
            create(:user_group, verified_at: DateTime.now)]
        end
        before do
          user_groups.each do |ug|
            create(:user_group_membership, user: current_user, user_group: ug)
          end
          current_user.reload
        end
        context "when user's user_groups are not verified" do
          it "should ignore them" do
            user_groups.each {|ug| ug.update_attribute :verified_at, nil}
            expected_groups_split= {adhere: [], unadhere: []}

            expect { command.call }.to broadcast :ok, expected_groups_split
          end
        end
        context "when all user user_groups are adhered" do
          it "should offer only user_groups to unahere" do
            user_groups.each {|ug| create(:proposal_adhesion,
              proposal: proposal, author: current_user, decidim_user_group_id: ug.id) }
            expected_groups_split= {adhere: [], unadhere: user_groups.collect {|ug| ug.id}}

            expect { command.call }.to broadcast :ok, expected_groups_split
          end
        end
        context "when half of user user_groups are adhered" do
          it "should offer the corresponding action to each user_groups" do
            create(:proposal_adhesion, proposal: proposal,
              author: current_user, decidim_user_group_id: user_groups.first.id)
            expected_groups_split= {adhere: [user_groups.last.id], unadhere: [user_groups.first.id]}

            expect { command.call }.to broadcast :ok, expected_groups_split
          end
        end
        context "when none of user's user_groups are adhered" do
          it "should offer all user_groups to adhere" do
            expected_groups_split= {adhere: user_groups.collect {|ug| ug.id}, unadhere: []}

            expect { command.call }.to broadcast :ok, expected_groups_split
          end
        end
      end

    end
  end
end
