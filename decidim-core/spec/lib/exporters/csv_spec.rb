# frozen_string_literal: true

require "spec_helper"
require "csv"

module Decidim
  describe Exporters::CSV do
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
            other_ids: @resource.ids
          }
        end
        # rubocop:enable RSpec/InstanceVariable
      end
    end

    let(:collection) do
      [
        OpenStruct.new(id: 1, name: { ca: "foocat", es: "fooes" }, ids: [1, 2, 3]),
        OpenStruct.new(id: 2, name: { ca: "barcat", es: "bares" }, ids: [1, 2, 3])
      ]
    end

    describe "export" do
      it "exports the collection using the right serializer" do
        exported = subject.export.read
        data = CSV.parse(exported, headers: true, col_sep: ";").map(&:to_h)
        expect(data[0]["serialized_name/ca"]).to eq("foocat")
      end
    end
  end
end
