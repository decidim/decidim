# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::Import::Readers
  describe JSON do
    let(:subject) { described_class.new(file) }
    let(:json_data) do
      <<~JSON
        [
          {
            "id": 1,
            "title": "Donec eget bibendum libero",
            "detail": "dapibus"
          },
          {
            "id": 2,
            "detail": "diam"
          },
          {
            "id": 3,
            "title": "Quisque non lacus ultrices"
          },
          {},
          {},
          {
            "id": 10
          }
        ]
      JSON
    end
    let(:file) do
      path = Rails.application.root.join("tmp/test_json.json")
      File.open(path, "w") do |f|
        f.write(json_data)
      end
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
        let(:json_data) do
          <<~JSON
            [
              {
                "id": 1,
                "title": Donec,
                "detail": dapibus
              }
            ]
          JSON
        end

        it "raises an error" do
          expect { subject.read_rows }.to raise_error(Decidim::Admin::Import::InvalidFileError)
        end
      end
    end
  end
end
