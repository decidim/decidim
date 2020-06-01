# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe ExportInitiativesJob do
      let(:organization) { create :organization }
      let!(:user) { create(:user, organization: organization) }

      it "sends an email with the result of the export" do
        perform_enqueued_jobs do
          described_class.perform_now(user, "CSV")
        end

        email = last_email
        expect(email.subject).to include("export")
        expect(email.body.encoded).to match("Please find attached a zipped version of your export.")
      end
    end
  end
end
