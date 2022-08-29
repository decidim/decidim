# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe AcceptGroupInvitation do
      describe "call" do
        let(:role) { "invited" }
        let(:membership) { create :user_group_membership, role: }
        let(:user) { membership.user }
        let(:user_group) { membership.user_group }

        let(:command) { described_class.new(user_group, user) }

        context "when the membership is not present" do
          let(:user) { create :user }
          let(:user_group) { create :user_group }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "sets the role as a member" do
            command.call
            membership.reload

            expect(membership.role).to eq "member"
          end
        end
      end
    end
  end
end
