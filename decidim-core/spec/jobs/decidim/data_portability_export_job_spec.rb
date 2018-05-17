# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DataPortabilityExportJob do
    # let!(:component) { create(:component, manifest_name: "dummy") }
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

    describe "CSV" do
      # it "exports the data portability entities" do
      #   exporter_double = double(export: true)
      #   class_double = double(new: exporter_double)
      #   expect(Decidim::Exporters::CSV)
      #     .to(receive(:new).with(anything, DummySerializer))
      #     .and_return(double(export: export_data))
      #
      # end

      # let(:export_data) { [ ["contents1", Decidim::Exporters::CSV.new("content", "csv")],["contents2", Decidim::Exporters::CSV.new("content2", "csv")]] }
      # it "uses the CSV exporter" do
      #   #TODO make the test exporter
      #
      #   expect(ExportMailer)
      #     .to(receive(:data_portability_export).with(user, anything, export_data))
      #     .and_return(double(deliver_now: true))
      #
      # end
    end
  end
end
