# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DataPortabilityExportJob do
    let(:organization) { create :organization }
    let!(:user) { create(:user, organization: organization) }

    it "sends an email with the result of the export" do
      DataPortabilityExportJob.perform_now(user, "exporter", "CSV")

      email = last_email
      expect(email.subject).to include("exporter")
      attachment = email.attachments.first

      expect(attachment.read.length).to be_positive
      expect(attachment.mime_type).to eq("application/zip")
      expect(attachment.filename).to match(/^exporter.*\.zip$/)
    end
  end
end
