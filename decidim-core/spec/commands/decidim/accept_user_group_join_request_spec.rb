# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe AcceptUserGroupJoinRequest do
      describe "call" do
        let(:role) { "requested" }
        let(:membership) { create :user_group_membership, role: }

        let(:command) { described_class.new(membership) }

        context "when the membership is not requested" do
          let(:role) { "member" }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "puts the role as a member" do
            command.call
            membership.reload

            expect(membership.role).to eq "member"
          end

          it "sends a notification" do
            expect(Decidim::EventsManager).to receive(:publish).with(
              hash_including(
                event: "decidim.events.groups.join_request_accepted",
                event_class: JoinRequestAcceptedEvent,
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
