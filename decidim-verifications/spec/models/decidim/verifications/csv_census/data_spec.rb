# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Verifications
    module CsvCensus
      describe Data do
        subject { csv_datum }

        let(:csv_datum) { create(:csv_datum) }
        let(:valid_csv) do
          Tempfile.new.tap do |f|
            f.write("user1@example.com\nuser2@example.com\n")
            f.rewind
          end
        end
        let(:invalid_csv) do
          Tempfile.new.tap do |f|
            f.write("user1@example.com\ninvalid_email\n")
            f.rewind
          end
        end
        let(:empty_csv) do
          Tempfile.new.tap do |f|
            f.write("")
            f.rewind
          end
        end
        let(:csv_with_headers) do
          Tempfile.new.tap do |f|
            f.write("Email\nuser1@example.com\n")
            f.rewind
          end
        end
        let(:multi_column_csv) do
          Tempfile.new.tap do |f|
            f.write("user1@example.com,extra_column\nuser2@example.com\n")
            f.rewind
          end
        end

        it { is_expected.to be_valid }

        context "without a valid email" do
          let(:csv_datum) { build(:csv_datum, email: "invalid_email") }

          it { is_expected.not_to be_valid }
        end

        describe "#read" do
          context "with a valid CSV file" do
            subject { described_class.new(valid_csv) }

            before { subject.read }

            it "parses all rows correctly" do
              expect(subject.values).to contain_exactly("user1@example.com", "user2@example.com")
              expect(subject.errors).to be_empty
            end
          end

          context "with an invalid CSV file" do
            subject { described_class.new(invalid_csv) }

            before { subject.read }

            it "parses valid rows and reports errors for invalid ones" do
              expect(subject.values).to contain_exactly("user1@example.com")
              expect(subject.errors).to include(["invalid_email"])
            end
          end

          context "with an empty CSV file" do
            subject { described_class.new(empty_csv) }

            before { subject.read }

            it "returns no values and no errors" do
              expect(subject.values).to be_empty
              expect(subject.errors).to be_empty
            end
          end

          context "with a CSV file containing headers" do
            subject { described_class.new(csv_with_headers) }

            before { subject.headers }

            it "reports headers as an error" do
              expect(subject.errors).to include(I18n.t("decidim.verifications.errors.has_headers"))
            end
          end

          context "with a CSV file having multiple columns" do
            subject { described_class.new(multi_column_csv) }

            before { subject.read }

            it "reports an error for unexpected column count" do
              expect(subject.errors).to include(I18n.t("decidim.verifications.errors.wrong_number_columns", expected: 1, actual: 2))
            end
          end

          context "with a malformed CSV file" do
            let(:malformed_csv) do
              Tempfile.new.tap do |f|
                f.write("bad_data\n\"unterminated_quote\n")
                f.rewind
              end
            end

            subject { described_class.new(malformed_csv) }

            before { subject.read }

            it "handles CSV parsing errors gracefully" do
              expect(subject.errors).to include(/Error: .*/)
            end
          end
        end

        describe "#count" do
          context "when no rows have been processed" do
            subject { described_class.new(empty_csv) }

            it "returns 0" do
              expect(subject.count).to eq(0)
            end
          end

          context "when rows have been processed" do
            subject { described_class.new(valid_csv) }

            before { subject.read }

            it "returns the number of columns in the file" do
              expect(subject.count).to eq(1)
            end
          end
        end

        describe "#headers" do
          context "when headers are present in the file" do
            subject { described_class.new(csv_with_headers) }

            it "returns the headers as an array" do
              expect(subject.headers).to contain_exactly("Email")
            end
          end

          context "when no headers are present" do
            subject { described_class.new(valid_csv) }

            it "returns an empty array" do
              expect(subject.headers).to be_empty
            end
          end
        end
      end
    end
  end
end
