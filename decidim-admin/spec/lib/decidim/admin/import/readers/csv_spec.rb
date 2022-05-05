# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::Import::Readers
  describe CSV do
    subject { described_class.new(file) }
    let(:csv_data) do
      <<~CSV
        id;title;detail
        1;Donec eget bibendum libero;dapibus
        2;;diam
        3;Quisque non lacus ultrices


        10
      CSV
    end
    let(:file) do
      path = Rails.application.root.join("tmp/test_csv.csv")
      File.write(path, csv_data)
      path
    end

    describe "#read_rows" do
      it "reads the non-empty data columns and provides nil values for empty columns and empty arrays for empty values" do
        data = []
        subject.read_rows do |rowdata|
          data << rowdata
        end

        expect(data).to eq(
          [
            %w(id title detail),
            ["1", "Donec eget bibendum libero", "dapibus"],
            ["2", nil, "diam"],
            ["3", "Quisque non lacus ultrices"],
            [],
            [],
            ["10"]
          ]
        )
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

      it "returns an example CSV file from the data" do
        expect(example).to be_a(StringIO)
        expect(example.read).to eq(
          <<~CSV
            id;title;detail
            1;Foo;bar
            2;Baz;biz
          CSV
        )
      end
    end
  end
end
