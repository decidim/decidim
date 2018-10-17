# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe JoinUserGroup do
      describe "call" do
        let(:organization) { create(:organization, :with_tos) }
        let(:user) { create :user, :confirmed, organization: organization }
        let(:user_group) { create :user_group, users: [], organization: organization }

        let(:command) { described_class.new(user, user_group) }

        context "when the user already has a membership with the group" do
          before do
            create :user_group_membership, user: user, user_group: user_group, role: "requested"
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new membership" do
            expect do
              command.call
            end.not_to change(Decidim::UserGroupMembership, :count)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new membership" do
            expect do
              command.call
            end.to change(Decidim::UserGroupMembership, :count).by(1)
            membership = Decidim::UserGroupMembership.last
            expect(membership.user).to eq user
            expect(membership.user_group).to eq user_group
            expect(membership.role).to eq "requested"
          end
        end
      end
    end
  end
end
