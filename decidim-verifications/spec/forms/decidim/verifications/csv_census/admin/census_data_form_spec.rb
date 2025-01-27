# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CensusDataForm do
    subject { described_class.from_params(file:) }

    describe "#data" do
      context "when the file is in invalid format" do
        let(:file) { Decidim::Dev.test_file("import_participatory_space_private_users_iso8859-1.csv", "text/csv") }

        it { is_expected.not_to be_nil }
      end

      context "when the file is empty" do
        let(:file) do
          Tempfile.new.tap do |f|
            f.write("")
            f.rewind
          end
        end

        it "adds an error about missing emails" do
          subject.csv_must_be_readable
          expect(subject.errors[:base]).to include(I18n.t("decidim.verifications.errors.no_emails"))
        end
      end

      context "when the file contains valid emails" do
        let(:file) do
          Tempfile.new.tap do |f|
            f.write("user1@example.com\nuser2@example.com\n")
            f.rewind
          end
        end

        it "does not add any errors" do
          subject.csv_must_be_readable
          expect(subject.errors).to be_empty
        end
      end

      context "when the file contains headers" do
        let(:file) do
          Tempfile.new.tap do |f|
            f.write("Email\nuser1@example.com\n")
            f.rewind
          end
        end

        it "adds an error for having headers" do
          subject.csv_must_be_readable
          expect(subject.errors[:base]).to include(I18n.t("decidim.verifications.errors.has_headers"))
        end
      end

      context "when the file contains more than one column" do
        let(:file) do
          Tempfile.new.tap do |f|
            f.write("user1@example.com,extra_column\nuser2@example.com\n")
            f.rewind
          end
        end

        it "adds an error about wrong column count" do
          subject.csv_must_be_readable
          expect(subject.errors[:base]).to include(I18n.t("decidim.verifications.errors.wrong_number_columns", expected: 1, actual: 2))
        end
      end

      context "when the file is malformed" do
        let(:file) do
          Tempfile.new.tap do |f|
            f.write("bad_data\n\"unterminated_quote\n")
            f.rewind
          end
        end

        it "does not crash and adds an error about malformed CSV" do
          expect { subject.csv_must_be_readable }.not_to raise_error
          expect(subject.errors[:base]).to include("The file must contain emails", "The file must not contain headers.")
        end
      end
    end
  end
end
