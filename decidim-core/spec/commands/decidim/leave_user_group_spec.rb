# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe LeaveUserGroup do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:membership) { create :user_group_membership, role: :admin }
        let(:user) { membership.user }
        let(:user_group) { membership.user_group }

        let(:command) { described_class.new(user, user_group) }

        context "when the user is the creator" do
          let(:membership) { create :user_group_membership, role: :creator }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the user has no membership with the group" do
          let(:user) { create :user }
          let(:user_group) { create :user_group }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the data is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "deletes the membership" do
            membership
            expect do
              command.call
            end.to change(Decidim::UserGroupMembership, :count).by(-1)
            expect do
              membership.reload
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
