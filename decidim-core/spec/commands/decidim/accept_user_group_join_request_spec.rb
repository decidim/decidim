# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe AcceptUserGroupJoinRequest do
      describe "call" do
        let(:role) { "requested" }
        let(:membership) { create :user_group_membership, role: role }

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
        end
      end
    end
  end
end
