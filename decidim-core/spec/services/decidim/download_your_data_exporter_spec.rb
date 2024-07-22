# frozen_string_literal: true

require "spec_helper"
require "decidim/seven_zip_wrapper"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, tmp_file_in, password) }

    let(:tmp_file_in) do
      Dir::Tmpname.create(["download-your-data", ".7z"]) do
        # just get an empty file name
      end
    end
    let(:tmp_dir_out) { Dir.mktmpdir("download_your_data_exporter_spec") }
    let(:password) { "download-your-data.7z>passwd" }
    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }
    let(:expected_files) do
      # this are the prefixes for the files that could have user generated content
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
      )
    end

    describe "#export" do
      it "compresses a password protected file" do
        expect(File.exist?(tmp_file_in)).to be false

        # generate 7z
        subject.export

        expect(File.exist?(tmp_file_in)).to be true

        open_7z_and_extract_zip(tmp_file_in)

        expect(Dir.entries(tmp_dir_out).count).to eq 4
      end
    end

    describe "#data_and_attachments_for_user" do
      it "returns an array of data for the user" do
        user_data, = subject.send(:data_and_attachments_for_user)

        file_prefixes = expected_files.dup
        user_data.each do |entity, exporter_data|
          entity_prefix = file_prefixes.find { |prefix| prefix.start_with?(entity) }
          expect(file_prefixes.delete(entity_prefix)).to be_present

          # we have an empty file  for each entity except for decidim-users
          expect(exporter_data.read).to eq("\n") unless entity == "decidim-users"
        end
        expect(file_prefixes).to be_empty
      end

      context "when the user has a comment" do
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:component) { create(:component, participatory_space:) }
        let(:commentable) { create(:dummy_resource, component:) }

        let!(:comment) { create(:comment, commentable:, author: user) }

        it "returns the comment data" do
          user_data, = subject.send(:data_and_attachments_for_user)

          user_data.find { |entity, _| entity == "decidim-comments-comments" }.tap do |_, exporter_data|
            csv_comments = exporter_data.read.split("\n")
            expect(csv_comments.count).to eq 2
            expect(csv_comments.first).to start_with "id;created_at;body;locale;author/id;author/name;alignment;depth;"
            expect(csv_comments.second).to start_with "#{comment.id};"
          end
        end
      end
    end

    private

    def open_7z_and_extract_zip(file_path)
      SevenZipWrapper.extract_and_decrypt(filename: file_path, password:, output_directory: tmp_dir_out)
    end
  end
end
