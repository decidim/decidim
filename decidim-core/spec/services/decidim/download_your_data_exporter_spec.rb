# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, tmp_file_in.path, password) }

    let(:tmp_file_in) { Tempfile.new(["download-your-data", ".7z"]) }
    let(:tmp_dir_out) { Dir.mktmpdir("download_your_data_exporter_spec") }
    let(:password) { "download-your-data.7z>passwd" }
    let(:user) { create :user }
    let(:expected_files) do
      # this are the prefixes for the files archived in the zip
      %w(
        decidim-follows-
        decidim-identities-
        decidim-messaging-conversations-
        decidim-notifications-
        decidim-participatoryspaceprivateusers-
        decidim-reports-
        decidim-users-
        decidim-usergroups-
        decidim-meetings-registrations-
        decidim-proposals-proposals-
        decidim-budgets-orders-
        decidim-forms-answers-
        decidim-debates-debates-
        decidim-conferences-conferenceregistrations-
        decidim-conferences-conferenceinvites-
        decidim-comments-comments-
        decidim-comments-commentvotes-
        decidim-users/avatar.jpg
      )
    end

    describe "#export" do
      it "compresses a password protected file" do
        # generate 7z
        subject.export

        open_7z_and_extract_zip(tmp_file_in.path)

        file_prefixes = expected_files.dup
        Zip::File.open(File.join(tmp_dir_out, DownloadYourDataExporter::ZIP_FILE_NAME)) do |zip_file|
          zip_file.each do |entry|
            entry_name = entry.name
            prefix = file_prefixes.find { |start| entry_name.start_with?(start) }
            expect(file_prefixes.delete(prefix)).to be_present
          end
        end
        expect(file_prefixes).to be_empty
      end
    end

    #----------------------------------------------------
    private

    #----------------------------------------------------

    def open_7z_and_extract_zip(file_path)
      File.open(file_path, "rb") do |file|
        SevenZipRuby::Reader.open_file(file, password:) do |szr|
          szr.extract(:all, tmp_dir_out)
        end
      end
    end
  end
end
