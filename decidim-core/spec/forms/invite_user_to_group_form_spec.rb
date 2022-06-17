# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InviteUserToGroupForm do
    subject do
      described_class.new(
        nickname:
      ).with_context(
        current_organization: organization
      )
    end

    let(:organization) { create :organization }
    let(:nickname) { "@does_not_exist" }

    context "with correct data" do
      let!(:user) { create :user, organization:, nickname: "my_nickname" }
      let(:nickname) { "@my_nickname" }

      it { is_expected.to be_valid }
    end

    context "when the user exists in another organization" do
      let!(:user) { create :user, nickname: "my_nickname" }
      let(:nickname) { "@my_nickname" }

      it { is_expected.not_to be_valid }
    end

    context "with an empty nickname" do
      let(:nickname) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when the nickname does not exist" do
      it { is_expected.not_to be_valid }
    end
  end
end
