# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::Import::Readers
  describe XLSX do
    subject { described_class.new(file) }
    let(:file) { Decidim::Dev.test_file("test_excel.xlsx", Decidim::Admin::Import::Readers::XLSX::MIME_TYPE) }

    describe "#read_rows" do
      it "reads the non-empty cells and provides nil values for empty cells and empty arrays for empty rows" do
        data = []
        subject.read_rows do |rowdata|
          data << rowdata
        end

        expect(data).to eq(
          [
            %w(id title detail),
            [1, "Donec eget bibendum libero", "dapibus"],
            [2, nil, "diam"],
            [3, "Quisque non lacus ultrices"],
            [],
            [],
            [10]
          ]
        )
      end

      context "with invalid file" do
        let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

        it "raises an error" do
          expect { subject.read_rows }.to raise_error(Decidim::Admin::Import::InvalidFileError)
        end
      end
    end

    describe "#example_file" do
      let(:data) do
        [
          %w(id title detail),
          [1, "Foo", "bar"],
          [2, "Baz", "biz"]
        ]
      end
      let(:example) { subject.example_file(data) }

      it "returns an example JSON file from the data" do
        expect(example).to be_a(StringIO)

        # The generated XLSX can have some byte differences which is why we need
        # to read the values from both files and compare them instead.
        workbook = RubyXL::Parser.parse_buffer(example)
        actual = workbook.worksheets[0].map { |row| row.cells.map(&:value) }

        expect(actual).to eq(data)
      end
    end
  end
end
