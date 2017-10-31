# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe RejectUserGroup do
    let(:organization) { create :organization }

    describe "User group validation is pending" do
      subject { described_class.new(user_group) }

      let!(:user_group) { create(:user_group, decidim_organization_id: organization.id, users: [create(:user, organization: organization)]) }

      context "when the command is not valid" do
        let(:invalid) { true }

        it "broadcast invalid in return" do
          expect(user_group).to receive(:valid?).and_return(false)
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
      end
    end

    describe "User group is already rejected" do
      subject { described_class.new(user_group) }

      let!(:user_group) { create(:user_group, decidim_organization_id: organization.id, verified_at: Time.current, users: [create(:user, organization: organization)]) }

      context "when the command is not valid" do
        let(:invalid) { true }

        it "broadcast invalid in return and do not clean verified_at" do
          expect(user_group).to receive(:valid?).and_return(false)
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
      end
    end
  end
end
