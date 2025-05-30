# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe CensusDataForm do
        let(:file) { upload_test_file(Decidim::Dev.test_file("valid_election_census.csv", "text/csv")) }
        let(:organization) { create(:organization) }

        subject do
          described_class.new(file:).with_context(current_organization: organization)
        end

        context "when the file is valid" do
          it { is_expected.to be_valid }

          it "parses data correctly" do
            expect(subject.data).to eq([%w(user1@example.org token123), %w(user2@example.org token456)])
            expect(subject.imported_count).to eq(2)
          end
        end

        context "when the file is missing" do
          let(:file) { nil }

          it { is_expected.to be_invalid }
        end

        context "when the file is not CSV" do
          let(:file) { upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")) }

          it { is_expected.to be_invalid }
        end

        context "when file has no header" do
          let(:file) { upload_test_file(Decidim::Dev.test_file("census_no_header.csv", "text/csv")) }

          it "parses no data and returns errors" do
            expect(subject.data).to be_empty
            expect(subject.errors_data).not_to be_empty
          end
        end

        context "when file has all invalid rows" do
          let(:file) { upload_test_file(Decidim::Dev.test_file("census_all_invalid.csv", "text/csv")) }

          it { is_expected.to be_valid }

          it "returns errors_data" do
            expect(subject.data).to be_empty
            expect(subject.errors_data).not_to be_empty
          end
        end

        context "when file has duplicate emails" do
          let(:file) { upload_test_file(Decidim::Dev.test_file("census_duplicate_emails.csv", "text/csv")) }

          it { is_expected.to be_valid }

          it "only imports unique records" do
            expect(subject.data.size).to eq(1)
            expect(subject.errors_data).to be_empty
          end
        end

        context "when file is missing email" do
          let(:file) { upload_test_file(Decidim::Dev.test_file("census_with_missing_email.csv", "text/csv")) }

          it { is_expected.to be_valid }

          it "returns missing email error" do
            expect(subject.data.size).to eq(1)
            expect(subject.errors_data).not_to be_empty
          end
        end

        context "when file is missing token" do
          let(:file) { upload_test_file(Decidim::Dev.test_file("census_with_missing_token.csv", "text/csv")) }

          it { is_expected.to be_valid }

          it "returns missing token error" do
            expect(subject.data.size).to eq(1)
            expect(subject.errors_data).not_to be_empty
          end
        end
      end
    end
  end
end
