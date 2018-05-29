# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FollowForm do
    subject { form }

    let(:user) { create :user }
    let(:followable) { create :dummy_resource }
    let(:params) do
      {
        followable_gid: followable.to_sgid
      }
    end

    let(:form) do
      described_class.from_params(params).with_context(current_user: user)
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when followable is the same as the current user" do
      let(:followable) { user }

      it { is_expected.to be_invalid }
    end

    context "when the followable_gid is not present" do
      let(:params) do
        {
          followable_gid: nil
        }
      end

      it { is_expected.to be_invalid }
    end
  end
end
