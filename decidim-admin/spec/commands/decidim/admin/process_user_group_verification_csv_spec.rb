# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ProcessUserGroupVerificationCsv do
    subject { described_class.new(form) }

    let(:user) { create(:user, :admin, organization:) }
    let(:organization) { create(:organization) }
    let(:file) { upload_test_file(Decidim::Dev.test_file("verify_user_groups.csv", "text/csv"), return_blob: true) }
    let(:validity) { true }

    let(:form) do
      double(
        current_user: user,
        current_organization: organization,
        file:,
        valid?: validity
      )
    end

    context "when the form is not valid" do
      let(:validity) { false }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end

      it "does not enqueue any job" do
        expect(VerifyUserGroupFromCsvJob).not_to receive(:perform_later)

        subject.call
      end
    end

    it "broadcasts ok" do
      expect(subject.call).to broadcast(:ok)
    end

    it "enqueues a job for each present value" do
      expect(VerifyUserGroupFromCsvJob).to receive(:perform_later).twice.with(kind_of(String), user, organization)

      subject.call
    end
  end
end
