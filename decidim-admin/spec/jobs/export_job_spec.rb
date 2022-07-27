# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ExportJob do
      let!(:component) { create(:component, manifest_name: "dummy") }
      let(:organization) { component.organization }
      let!(:user) { create(:user, organization:) }

      it "sends an email with the result of the export" do
        ExportJob.perform_now(user, component, "dummies", "CSV")

        email = last_email
        expect(email.subject).to include("dummies")
        attachment = email.attachments.first

        expect(attachment.read.length).to be_positive
        expect(attachment.mime_type).to eq("application/zip")
        expect(attachment.filename).to match(/^dummies-[0-9]+-[0-9]+-[0-9]+-[0-9]+\.zip$/)
      end

      describe "CSV" do
        it "uses the CSV exporter" do
          export_data = double

          expect(Decidim::Exporters::CSV)
            .to(receive(:new).with(anything, DummySerializer))
            .and_return(double(export: export_data))

          expect(ExportMailer)
            .to(receive(:export).with(user, anything, export_data))
            .and_return(double(deliver_now: true))

          ExportJob.perform_now(user, component, "dummies", "CSV")
        end
      end

      describe "JSON" do
        it "uses the JSON exporter" do
          export_data = double

          expect(Decidim::Exporters::JSON)
            .to(receive(:new).with(anything, DummySerializer))
            .and_return(double(export: export_data))

          expect(ExportMailer)
            .to(receive(:export).with(user, anything, export_data))
            .and_return(double(deliver_now: true))

          ExportJob.perform_now(user, component, "dummies", "JSON")
        end
      end
    end
  end
end
