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
      it "uses the CSV exporter" do
        export_data = [ ]
        objects = [ DummyResources::DummyResource ]

        #TODO tests This

        # objects.each do |object|
        #   export_data << [object.model_name.name.parameterize.pluralize, expect(Decidim::Exporters::CSV)
        #   .to(receive(:new).with(object.user_collection(user), object.export_serializer))
        #   .and_return(double(export: export_data))]
        # end

        # objects.each do |object|
        #   export_data << [object.model_name.name.parameterize.pluralize]
        # end

        expect(ExportMailer)
          .to(receive(:data_portability_export).with(user, anything, export_data))
          .and_return(double(deliver_now: true))

        DataPortabilityExportJob.perform_now(user, "exporter", "CSV")
      end
    end
  end
end
