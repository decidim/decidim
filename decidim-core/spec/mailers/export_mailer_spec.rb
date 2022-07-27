# frozen_string_literal: true

require "spec_helper"
require "zip"

module Decidim
  describe ExportMailer, type: :mailer do
    let(:user) { create(:user, name: "Sarah Connor", organization:) }
    let!(:organization) { create(:organization) }

    describe "export" do
      let(:export_data) { Decidim::Exporters::ExportData.new("content", "txt") }
      let(:mail) { described_class.export(user, "dummy", export_data) }

      it "sets a subject" do
        expect(mail.subject).to include("dummy", "ready")
      end

      it "zips the export" do
        expect(mail.attachments.length).to eq(1)

        attachment = mail.attachments.first
        expect(attachment.filename).to match(/^dummy-[0-9]+-[0-9]+-[0-9]+-[0-9]+\.zip$/)

        entries = []
        Zip::InputStream.open(StringIO.new(attachment.read)) do |io|
          while (entry = io.get_next_entry)
            entries << { name: entry.name, content: entry.get_input_stream.read }
          end
        end

        expect(entries.length).to eq(1)

        entry = entries.first
        expect(entry[:name]).to match(/^dummy-[0-9]+-[0-9]+-[0-9]+-[0-9]+\.txt$/)
        expect(entry[:content]).to eq("content")
      end
    end

    describe "download your data export" do
      object = "Decidim::DummyResources::DummyResource"
      klass = Object.const_get(object)
      let(:export_data) { [[klass.model_name.name.parameterize.pluralize, Decidim::Exporters.find_exporter("CSV").new(klass.user_collection(user), klass.export_serializer).export]] }
      let(:images) { [] }
      let(:mail) { described_class.download_your_data_export(user, export_data, images) }

      it "sets a subject" do
        expect(mail.subject).to include("Sarah Connor", "ready")
      end

      it "has a link" do
        expect(mail).to have_link("Download")
      end
    end
  end
end
