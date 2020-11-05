# frozen_string_literal: true

require "spec_helper"
require "spreadsheet"

module Decidim
  describe Exporters::Excel do
    subject { described_class.new(collection, serializer) }

    let(:serializer) do
      Class.new do
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
      end
    end

    let(:collection) do
      [
        OpenStruct.new(id: 1, name: { ca: "foocat", es: "fooes" }, ids: [1, 2, 3], float: 1.66, date: Time.zone.local(2017, 10, 1, 5, 0)),
        OpenStruct.new(id: 2, name: { ca: "barcat", es: "bares" }, ids: [2, 3, 4], float: 0.55, date: Time.zone.local(2017, 9, 20)),
        OpenStruct.new(id: 3, name: { ca: "@atcat", es: "@ates" }, ids: [1, 2, 3], float: 0.35, date: Time.zone.local(2020, 7, 20)),
        OpenStruct.new(id: 4, name: { ca: "=equalcat", es: "=equales" }, ids: [1, 2, 3], float: 0.45, date: Time.zone.local(2020, 6, 24)),
        OpenStruct.new(id: 5, name: { ca: "+pluscat", es: "+pluses" }, ids: [1, 2, 3], float: 0.65, date: Time.zone.local(2020, 7, 15)),
        OpenStruct.new(id: 6, name: { ca: "-minuscat", es: "-minuses" }, ids: [1, 2, 3], float: 0.75, date: Time.zone.local(2020, 6, 27))
      ]
    end

    describe "export" do
      it "exports the collection using the right serializer" do
        exported = StringIO.new(subject.export.read)
        book = Spreadsheet.open(exported)
        worksheet = book.worksheet(0)
        expect(worksheet.rows.length).to eq(7)

        headers = worksheet.rows[0]
        expect(headers).to eq(["id", "serialized_name/ca", "serialized_name/es", "other_ids", "float", "date"])
        expect(worksheet.rows[1][0..4]).to eq([1, "foocat", "fooes", "1, 2, 3", 1.66])
        expect(worksheet.rows[1].datetime(5)).to eq(Time.zone.local(2017, 10, 1, 5, 0))

        expect(worksheet.rows[2][0..4]).to eq([2, "barcat", "bares", "2, 3, 4", 0.55])
        expect(worksheet.rows[2].datetime(5)).to eq(Time.zone.local(2017, 9, 20))
      end
    end

    describe "export sanitizer" do
      it "exports the collection sanitizing invalid first chars correctly" do
        exported = StringIO.new(subject.export.read)
        book = Spreadsheet.open(exported)
        worksheet = book.worksheet(0)

        headers = worksheet.rows[0]
        expect(headers).to eq(["id", "serialized_name/ca", "serialized_name/es", "other_ids", "float", "date"])
        expect(worksheet.rows[1][0..4]).to eq([1, "foocat", "fooes", "1, 2, 3", 1.66])
        expect(worksheet.rows[1].datetime(5)).to eq(Time.zone.local(2017, 10, 1, 5, 0))

        expect(worksheet.rows[2][0..4]).to eq([2, "barcat", "bares", "2, 3, 4", 0.55])
        expect(worksheet.rows[2].datetime(5)).to eq(Time.zone.local(2017, 9, 20))

        expect(worksheet.rows[3][0..4]).to eq([3, "'@atcat", "'@ates", "1, 2, 3", 0.35])
        expect(worksheet.rows[3].datetime(5)).to eq(Time.zone.local(2020, 7, 20))

        expect(worksheet.rows[4][0..4]).to eq([4, "'=equalcat", "'=equales", "1, 2, 3", 0.45])
        expect(worksheet.rows[4].datetime(5)).to eq(Time.zone.local(2020, 6, 24))

        expect(worksheet.rows[5][0..4]).to eq([5, "'+pluscat", "'+pluses", "1, 2, 3", 0.65])
        expect(worksheet.rows[5].datetime(5)).to eq(Time.zone.local(2020, 7, 15))

        expect(worksheet.rows[6][0..4]).to eq([6, "'-minuscat", "'-minuses", "1, 2, 3", 0.75])
        expect(worksheet.rows[6].datetime(5)).to eq(Time.zone.local(2020, 6, 27))
      end
    end
  end
end
