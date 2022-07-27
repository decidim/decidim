# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe InviteUserToGroup do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:user) { create :user, :confirmed, organization: }
        let(:user_group) { create :user_group, users: [], organization: }
        let(:nickname) { user.nickname }
        let(:form) do
          Decidim::InviteUserToGroupForm.new(
            nickname:
          ).with_context(
            current_organization: organization
          )
        end

        let(:command) { described_class.new(form, user_group) }

        context "when the user already has a membership with the group" do
          let!(:membership) do
            create :user_group_membership, user:, user_group:, role: "requested"
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "doesn't send a notification" do
            expect(Decidim::EventsManager).not_to receive(:publish)
            command.call
          end

          it "doesn't modify the membership" do
            expect do
              command.call
              membership.reload
            end.not_to change(membership, :role)
          end
        end

        context "when the form is invalid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
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
            expect(membership.role).to eq "invited"
          end

          it "sends a notification" do
            expect(Decidim::EventsManager).to receive(:publish).with(
              hash_including(
                event: "decidim.events.groups.invited_to_group",
                event_class: InvitedToGroupEvent,
                resource: user_group,
                affected_users: [user],
                extra: {
                  user_group_name: user_group.name,
                  user_group_nickname: user_group.nickname
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
