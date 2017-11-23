# frozen_string_literal: true

require "spec_helper"
require "spreadsheet"

module Decidim
  describe Exporters::Excel do
    subject { described_class.new(collection, serializer) }

    let(:serializer) do
      Class.new do
        # rubocop:disable RSpec/InstanceVariable
        def initialize(resource)
          @resource = resource
        end

        def serialize
          {
            id: @resource.id,
            serialized_name: @resource.name,
            other_ids: @resource.ids,
            float: @resource.float,
            date: @resource.date
          }
        end
        # rubocop:enable RSpec/InstanceVariable
      end
    end

    let(:collection) do
      [
        OpenStruct.new(id: 1, name: { ca: "foocat", es: "fooes" }, ids: [1, 2, 3], float: 1.66, date: DateTime.civil(2017, 10, 1, 5, 0)),
        OpenStruct.new(id: 2, name: { ca: "barcat", es: "bares" }, ids: [2, 3, 4], float: 0.55, date: DateTime.civil(2017, 9, 20))
      ]
    end

    describe "export" do
      it "exports the collection using the right serializer" do
        exported = StringIO.new(subject.export.read)
        book = Spreadsheet.open(exported)
        worksheet = book.worksheet(0)
        expect(worksheet.rows.length).to eq(3)

        headers = worksheet.rows[0]
        expect(headers).to eq(["id", "serialized_name/ca", "serialized_name/es", "other_ids", "float", "date"])
        expect(worksheet.rows[1][0..4]).to eq([1, "foocat", "fooes", "1, 2, 3", 1.66])
        expect(worksheet.rows[1].datetime(5)).to eq(DateTime.civil(2017, 10, 1, 5, 0))

        expect(worksheet.rows[2][0..4]).to eq([2, "barcat", "bares", "2, 3, 4", 0.55])
        expect(worksheet.rows[2].datetime(5)).to eq(DateTime.civil(2017, 9, 20))
      end
    end
  end
end
