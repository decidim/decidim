# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::VerifyUserGroup do
  let(:organization) { create :organization }

  describe "User group validation is pending" do
    let!(:user_group) { create(:user_group, users: [create(:user, organization: organization)]) }

    subject { described_class.new(user_group) }

    context "when the command is not valid" do
      before do
        allow(user_group).to receive(:update_attributes!).and_raise(ActiveRecord::RecordInvalid)
      end

      let(:invalid) { true }

      it "broadcast invalid in return" do
        expect { subject.call }.to broadcast(:invalid)

        expect(user_group.rejected_at).to be_nil
        expect(user_group.verified_at).to be_nil
      end
    end

    context "when the command is valid" do
      it "the user group is rejected" do
        expect { subject.call }.to broadcast(:ok)

        expect(user_group.rejected_at).to be_nil
        expect(user_group.verified_at).not_to be_nil
      end
    end
  end

  describe "User group is already rejected" do
    let!(:user_group) { create(:user_group, rejected_at: Time.current, users: [create(:user, organization: organization)]) }

    subject { described_class.new(user_group) }

    context "when the command is not valid" do
      before do
        allow(user_group).to receive(:update_attributes!).and_raise(ActiveRecord::RecordInvalid)
      end

      let(:invalid) { true }

      it "broadcast invalid in return and do not clean rejected_at" do
        expect { subject.call }.to broadcast(:invalid)

        expect(user_group.rejected_at).not_to be_nil
        expect(user_group.verified_at).to be_nil
      end
    end

    context "when the command is valid" do
      it "the user group is verified" do
        expect { subject.call }.to broadcast(:ok)

        expect(user_group.rejected_at).to be_nil
        expect(user_group.verified_at).not_to be_nil
      end
    end
  end
end
