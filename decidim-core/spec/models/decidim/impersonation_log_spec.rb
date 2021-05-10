# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ImpersonationLog do
    subject { impersonation_log }

    let(:impersonation_log) { build(:impersonation_log) }

    it { is_expected.to be_valid }

    context "when the admin is not from the same organization as the user" do
      before do
        subject.admin = create(:user, :admin)
      end

      it { is_expected.not_to be_valid }
    end

    context "when the admin has already an active impersonation" do
      before do
        create(:impersonation_log, admin: subject.admin)
      end

      it { is_expected.not_to be_valid }
    end
  end
end
