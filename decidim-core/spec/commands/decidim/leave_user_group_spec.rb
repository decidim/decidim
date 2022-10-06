# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe LeaveUserGroup do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:membership) { create :user_group_membership, role: }
        let(:role) { :admin }
        let(:user) { membership.user }
        let(:user_group) { membership.user_group }

        let(:command) { described_class.new(user, user_group) }

        context "when the user is the creator" do
          let(:role) { :creator }

          it "broadcasts last admin cant leave group" do
            expect { command.call }.to broadcast(:last_admin)
          end

          context "and there is another admin in the group" do
            let!(:another_membership) { create(:user_group_membership, user_group:, role: :admin) }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end
          end

          context "and there is another member in the group" do
            let!(:another_membership) { create(:user_group_membership, user_group:, role: :member) }

            it "doesnt allow last admin to leave the group" do
              expect { command.call }.to broadcast(:last_admin)
            end
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
          let(:role) { :member }

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
