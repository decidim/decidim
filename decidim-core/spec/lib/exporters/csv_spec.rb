# frozen_string_literal: true

require "spec_helper"
require "csv"

module Decidim
  describe Exporters::CSV do
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
            other_ids: @resource.ids
          }
        end
      end
    end

    let(:collection) do
      [
        OpenStruct.new(id: 1, name: { ca: "foocat", es: "fooes" }, ids: [1, 2, 3]),
        OpenStruct.new(id: 2, name: { ca: "barcat", es: "bares" }, ids: [1, 2, 3]),
        OpenStruct.new(id: 3, name: { ca: "@atcat", es: "@ates" }, ids: [1, 2, 3]),
        OpenStruct.new(id: 4, name: { ca: "=equalcat", es: "=equales" }, ids: [1, 2, 3]),
        OpenStruct.new(id: 5, name: { ca: "+pluscat", es: "+pluses" }, ids: [1, 2, 3]),
        OpenStruct.new(id: 6, name: { ca: "-minuscat", es: "-minuses" }, ids: [1, 2, 3])
      ]
    end

    describe "export" do
      it "exports the collection using the right serializer" do
        exported = subject.export.read
        data = CSV.parse(exported, headers: true, col_sep: ";").map(&:to_h)
        expect(data[0]["serialized_name/ca"]).to eq("foocat")
      end

      context "with items in heterogeneous locales" do
        let(:collection) do
          [
            OpenStruct.new(id: 1, name: { ca: "name cat" }, body: { ca: "body cat" }),
            OpenStruct.new(id: 2, name: { es: "name es" }, body: { es: "body es" }),
            OpenStruct.new(id: 3, name: { en: "name en" }, ids: { en: "body en" })
          ]
        end

        it "exports all locales" do
          exported = subject.export.read
          data = CSV.parse(exported, headers: true, col_sep: ";").map(&:to_h)
          3.times do |idx|
            expect(data[idx]).to have_key("serialized_name/ca")
            expect(data[idx]).to have_key("serialized_name/en")
            expect(data[idx]).to have_key("serialized_name/es")
          end
        end
      end
    end

    describe "export sanitizer" do
      it "exports the collection sanitizing invalid first chars correctly" do
        exported = subject.export.read
        data = CSV.parse(exported, headers: true, col_sep: ";").map(&:to_h)
        expect(data[0]["serialized_name/ca"]).to eq("foocat")
        expect(data[1]["serialized_name/ca"]).to eq("barcat")
        expect(data[2]["serialized_name/ca"]).to eq("'@atcat")
        expect(data[2]["serialized_name/es"]).to eq("'@ates")
        expect(data[3]["serialized_name/ca"]).to eq("'=equalcat")
        expect(data[3]["serialized_name/es"]).to eq("'=equales")
        expect(data[4]["serialized_name/ca"]).to eq("'+pluscat")
        expect(data[4]["serialized_name/es"]).to eq("'+pluses")
        expect(data[5]["serialized_name/ca"]).to eq("'-minuscat")
        expect(data[5]["serialized_name/es"]).to eq("'-minuses")
      end
    end
  end
end
