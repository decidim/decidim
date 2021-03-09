# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::Excel do
    subject { described_class.new(collection, serializer) }

    let(:serializer) do
      Class.new do
        def initialize(resource)
          @resource = resource
        end

        def run
          serialize
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
        workbook = RubyXL::Parser.parse_buffer(exported)
        worksheet = workbook[0]
        expect(worksheet.sheet_data.rows.length).to eq(7)

        headers = worksheet[0].cells.map(&:value)
        expect(headers).to eq(["id", "serialized_name/ca", "serialized_name/es", "other_ids", "float", "date"])

        expect(worksheet[1][0..4].map(&:value)).to eq([1, "foocat", "fooes", "1, 2, 3", 1.66])

        expect(Time.zone.parse(worksheet[1][5].value.to_s)).to eq(Time.zone.local(2017, 10, 1, 5, 0))

        expect(worksheet[2][0..4].map(&:value)).to eq([2, "barcat", "bares", "2, 3, 4", 0.55])
        expect(Time.zone.parse(worksheet[2][5].value.to_s)).to eq(Time.zone.local(2017, 9, 20))
      end
    end

    describe "export sanitizer" do
      it "exports the collection sanitizing invalid first chars correctly" do
        exported = StringIO.new(subject.export.read)
        workbook = RubyXL::Parser.parse_buffer(exported)
        worksheet = workbook[0]

        headers = worksheet[0].cells.map(&:value)
        expect(headers).to eq(["id", "serialized_name/ca", "serialized_name/es", "other_ids", "float", "date"])
        expect(worksheet[1][0..4].map(&:value)).to eq([1, "foocat", "fooes", "1, 2, 3", 1.66])

        expect(Time.zone.parse(worksheet[1][5].value.to_s)).to eq(Time.zone.local(2017, 10, 1, 5, 0))

        expect(worksheet[2][0..4].map(&:value)).to eq([2, "barcat", "bares", "2, 3, 4", 0.55])
        expect(Time.zone.parse(worksheet[2][5].value.to_s)).to eq(Time.zone.local(2017, 9, 20))

        expect(worksheet[3][0..4].map(&:value)).to eq([3, "'@atcat", "'@ates", "1, 2, 3", 0.35])
        expect(Time.zone.parse(worksheet[3][5].value.to_s)).to eq(Time.zone.local(2020, 7, 20))

        expect(worksheet[4][0..4].map(&:value)).to eq([4, "'=equalcat", "'=equales", "1, 2, 3", 0.45])
        expect(Time.zone.parse(worksheet[4][5].value.to_s)).to eq(Time.zone.local(2020, 6, 24))

        expect(worksheet[5][0..4].map(&:value)).to eq([5, "'+pluscat", "'+pluses", "1, 2, 3", 0.65])
        expect(Time.zone.parse(worksheet[5][5].value.to_s)).to eq(Time.zone.local(2020, 7, 15))

        expect(worksheet[6][0..4].map(&:value)).to eq([6, "'-minuscat", "'-minuses", "1, 2, 3", 0.75])
        expect(Time.zone.parse(worksheet[6][5].value.to_s)).to eq(Time.zone.local(2020, 6, 27))
      end
    end

    context "when export dates" do
      subject { described_class.new(collection, serializer) }

      let(:collection) do
        [
          OpenStruct.new(id: 1, title: { ca: "such", es: "wow" }, start_date: Date.strptime("08-07-2020", "%d-%m-%Y")),
          OpenStruct.new(id: 2, title: { ca: "many", es: "much" }, start_date: Date.strptime("13-01-2021", "%d-%m-%Y"))
        ]
      end

      let(:serializer) do
        Class.new do
          def initialize(resource)
            @resource = resource
          end

          def run
            serialize
          end

          def serialize
            {
              id: @resource.id,
              title: @resource.title,
              start_date: @resource.start_date
            }
          end
        end
      end

      it "formats cells into dd.mm.yyyy" do
        exported = StringIO.new(subject.export.read)
        workbook = RubyXL::Parser.parse_buffer(exported)
        worksheet = workbook[0]
        headers = worksheet[0].cells.map(&:value)

        expect(headers).to eq(%w(id title/ca title/es start_date))

        expect(worksheet[1][0..2].map(&:value)).to eq([1, "such", "wow"])
        expect(worksheet[1][3].number_format.format_code).to eq("dd.mm.yyyy")
        expect(worksheet[1][3].value).to eq(Date.strptime("08-07-2020", "%d-%m-%Y"))

        expect(worksheet[2][0..2].map(&:value)).to eq([2, "many", "much"])
        expect(worksheet[2][3].number_format.format_code).to eq("dd.mm.yyyy")
        expect(worksheet[2][3].value).to eq(Date.strptime("13-01-2021", "%d-%m-%Y"))
      end
    end
  end
end
