# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ProcessParticipatorySpacePrivateUserImportCsv do
    subject { described_class.new(form, current_user, private_users_to) }

    let(:current_user) { create(:user, :admin, organization: organization) }
    let(:organization) { create(:organization) }
    let(:private_users_to) { create :participatory_process, organization: organization }
    let(:file) { File.new Decidim::Dev.asset("import_participatory_space_private_users.csv") }
    let(:validity) { true }

    let(:form) do
      double(
        current_user: current_user,
        private_users_to: private_users_to,
        current_organization: organization,
        file: file,
        valid?: validity
      )
    end

    context "when the form is not valid" do
      let(:validity) { false }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end

      it "does not enqueue any job" do
        expect(ImportParticipatorySpacePrivateUserCsvJob).not_to receive(:perform_later)

        subject.call
      end
    end

    it "broadcasts ok" do
      expect(subject.call).to broadcast(:ok)
    end

    it "enqueues a job for each present value" do
      expect(ImportParticipatorySpacePrivateUserCsvJob).to receive(:perform_later).twice.with(kind_of(String), kind_of(String), private_users_to, current_user)

      subject.call
    end
  end
end
