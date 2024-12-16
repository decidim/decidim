# frozen_string_literal: true

require "spec_helper"
require "zip"

module Decidim
  describe ExportMailer do
    let(:decidim) { Decidim::Core::Engine.routes.url_helpers }

    let(:user) { create(:user, name: "Sarah Connor", organization:) }
    let!(:organization) { create(:organization) }

    describe "export" do
      let(:mail) { described_class.export(user, private_download) }
      let!(:private_download) { Decidim::DownloadYourDataExporter.new(user, "dummy", Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT).export }

      it "sets a subject" do
        expect(mail.subject).to include("dummy", "ready")
      end

      it "has expiration date" do
        expect(mail).to have_content("The file will be available for download until")
        expect(mail).to have_content(private_download.expires_at.strftime("%d/%m/%Y %H:%M"))
      end

      it "has a link" do
        expect(mail).to have_link("Download", href: decidim.download_download_your_data_url(private_download, host: organization.host))
      end
    end

    describe "download your data export" do
      let(:images) { [] }
      let!(:private_download) { Decidim::DownloadYourDataExporter.new(user, "download_your_data", Decidim::DownloadYourDataExporter::DEFAULT_EXPORT_FORMAT).export }

      let(:mail) { described_class.download_your_data_export(user, private_download) }

      it "sets a subject" do
        expect(mail.subject).to include("Sarah Connor", "ready")
      end

      it "has expiration date" do
        expect(mail).to have_content("The file will be available for download until")
        expect(mail).to have_content(private_download.expires_at.strftime("%d/%m/%Y %H:%M"))
      end

      it "has a link" do
        expect(mail).to have_link("Download", href: decidim.download_download_your_data_url(private_download, host: organization.host))
      end
    end
  end
end
