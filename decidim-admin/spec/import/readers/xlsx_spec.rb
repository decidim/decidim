# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::Import::Readers
  describe XLSX do
    let(:subject) { described_class.new(file) }
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
          expect { subject.read_rows }.to raise_error(Zip::Error)
        end
      end
    end
  end
end
