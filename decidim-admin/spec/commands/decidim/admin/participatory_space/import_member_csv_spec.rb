# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::ParticipatorySpace
  describe ImportMemberCsv do
    subject { described_class.new(form, members_to) }

    let(:current_user) { create(:user, :admin, organization:) }
    let(:organization) { create(:organization) }
    let(:members_to) { create(:participatory_process, organization:) }
    let(:file) { upload_test_file(Decidim::Dev.test_file("import_members.csv", "text/csv"), return_blob: true) }
    let(:validity) { true }

    let(:form) do
      double(
        current_user:,
        members_to:,
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
        expect(ImportMemberCsvJob).not_to receive(:perform_later)

        subject.call
      end
    end

    context "when the CSV file has BOM" do
      let(:file) { upload_test_file(Decidim::Dev.test_file("import_members_with_bom.csv", "text/csv"), return_blob: true) }
      let(:email) { "john.doe@example.org" }

      it "broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end

      it "enqueues a job for each present value without BOM" do
        expect(ImportMemberCsvJob).to receive(:perform_later).with(email, kind_of(String), members_to, current_user)

        subject.call
      end
    end

    it "broadcasts ok" do
      expect(subject.call).to broadcast(:ok)
    end

    it "enqueues a job for each present value" do
      expect(ImportMemberCsvJob).to receive(:perform_later).twice.with(kind_of(String), kind_of(String), members_to, current_user)

      subject.call
    end
  end
end
