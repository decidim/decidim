# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe RemoveUserFromGroup do
      describe "call" do
        let(:role) { "member" }
        let(:membership) { create :user_group_membership, role: }
        let(:user_group) { membership.user_group }

        let(:command) { described_class.new(membership, user_group) }

        context "when the membership does not match the user group" do
          let(:user_group) { create :user_group }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the membership is not present" do
          let(:membership) { nil }
          let(:user_group) { create :user_group }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "removes the membership" do
            membership
            expect do
              command.call
            end.to change(Decidim::UserGroupMembership, :count).by(-1)
            expect do
              membership.reload
            end.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "sends a notification" do
            expect(Decidim::EventsManager).to receive(:publish).with(
              hash_including(
                event: "decidim.events.groups.removed_from_group",
                event_class: RemovedFromGroupEvent,
                resource: membership.user_group,
                affected_users: [membership.user],
                extra: {
                  user_group_name: membership.user_group.name,
                  user_group_nickname: membership.user_group.nickname
                }
              )
            )
            command.call
          end
        end
      end
    end
  end
end
