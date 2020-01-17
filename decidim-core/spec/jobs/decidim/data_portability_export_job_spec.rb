# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DataPortabilityExportJob do
    let(:organization) { create :organization }
    let!(:user) { create(:user, organization: organization) }

    it "sends an email with the result of the export" do
      perform_enqueued_jobs do
        DataPortabilityExportJob.perform_now(user, "CSV")
      end

      email = last_email
      expect(email.subject).to include("export")
      expect(email.body.encoded).to match("Download")
    end
  end
end
