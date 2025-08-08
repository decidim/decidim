# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ExportJob do
      let!(:component) { create(:component, manifest_name: "dummy") }
      let(:organization) { component.organization }
      let!(:user) { create(:user, organization:) }

      it "sends an email with the result of the export" do
        perform_enqueued_jobs { ExportJob.perform_now(user, component, "dummies", "CSV") }

        email = last_email
        expect(email.subject).to include("dummies")
        expect(last_email_body).to include("Your download is ready.")
      end

      describe "CSV" do
        it "uses the CSV exporter" do
          export_data = double(read: "", filename: "dummies")

          expect(Decidim::Exporters::CSV)
            .to(receive(:new).with(anything, Decidim::Dev::DummySerializer))
            .and_return(double(export: export_data))

          expect(ExportMailer)
            .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
            .and_return(double(deliver_later: true))

          ExportJob.perform_now(user, component, "dummies", "CSV")
        end
      end

      describe "JSON" do
        it "uses the JSON exporter" do
          export_data = double(read: "", filename: "dummies")

          expect(Decidim::Exporters::JSON)
            .to(receive(:new).with(anything, Decidim::Dev::DummySerializer))
            .and_return(double(export: export_data))

          expect(ExportMailer)
            .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
            .and_return(double(deliver_later: true))

          ExportJob.perform_now(user, component, "dummies", "JSON")
        end
      end
    end
  end
end
