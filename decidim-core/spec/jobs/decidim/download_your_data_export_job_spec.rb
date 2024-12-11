# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataExportJob do
    let(:organization) { create(:organization) }
    let!(:user) { create(:user, organization:) }

    it "sends an email with the result of the export" do
      perform_enqueued_jobs do
        DownloadYourDataExportJob.perform_now(user, "CSV")
      end

      email = last_email
      expect(email.subject).to include("export")
      expect(email.body.encoded).to match("Download")
    end

    it "deletes the temporary file after finishing the job" do
      user = create(:user)

      expect(Decidim::PrivateExport.count).to eq(0)

      described_class.perform_now(user)

      expect(Decidim::PrivateExport.count).to eq(1)
      expect(Decidim::PrivateExport.last.export_type).to eq("download_your_data")
      expect(user.reload.private_exports.last.file.attached?).to be(true)
    end
  end
end
