# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe RejectUserGroup do
    subject { described_class.new(user_group, current_user) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, organization: organization }

    describe "User group validation is pending" do
      let!(:user_group) { create(:user_group, decidim_organization_id: organization.id, users: [create(:user, organization: organization)]) }

      context "when the command is not valid" do
        let(:invalid) { true }

        it "broadcast invalid in return" do
          allow(user_group).to receive(:valid?).and_return(false)
          expect { subject.call }.to broadcast(:invalid)

          expect(user_group.rejected_at).to be_nil
          expect(user_group.verified_at).to be_nil
        end
      end

      context "when the command is valid" do
        it "the user group is rejected" do
          expect { subject.call }.to broadcast(:ok)

          expect(user_group.verified_at).to be_nil
          expect(user_group.rejected_at).not_to be_nil
        end

        it "tracks the changes" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("reject", user_group, current_user)

          subject.call
        end
      end
    end

    describe "User group is already rejected" do
      let!(:user_group) { create(:user_group, decidim_organization_id: organization.id, verified_at: Time.current, users: [create(:user, organization: organization)]) }

      context "when the command is not valid" do
        let(:invalid) { true }

        it "broadcast invalid in return and do not clean verified_at" do
          allow(user_group).to receive(:valid?).and_return(false)
          expect { subject.call }.to broadcast(:invalid)

          expect(user_group.verified_at).not_to be_nil
          expect(user_group.rejected_at).to be_nil
        end
      end

      context "when the command is valid" do
        it "the user group is rejected" do
          expect { subject.call }.to broadcast(:ok)

          expect(user_group.verified_at).to be_nil
          expect(user_group.rejected_at).not_to be_nil
        end

        it "tracks the changes" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("reject", user_group, current_user)

          subject.call
        end
      end
    end
  end
end
