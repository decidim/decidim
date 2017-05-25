# frozen_string_literal: true

require "spec_helper"
require "csv"

describe Decidim::Exporters::CSV do
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
      OpenStruct.new(id: 2, name: { ca: "barcat", es: "bares" }, ids: [1, 2, 3])
    ]
  end

  subject { described_class.new(collection, serializer) }

  describe "export" do
    it "exports the collection using the right serializer" do
      exported = subject.export.read
      data = CSV.parse(exported, headers: true, col_sep: ";").map(&:to_h)
      expect(data[0]["serialized_name/ca"]).to eq("foocat")
    end
  end
end
