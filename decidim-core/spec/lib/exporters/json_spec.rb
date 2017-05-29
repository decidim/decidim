# frozen_string_literal: true

require "spec_helper"

describe Decidim::Exporters::JSON do
  let(:serializer) do
    Class.new do
      def initialize(resource)
        @resource = resource
      end

      def serialize
        {
          id: @resource.id,
          serialized_name: @resource.name
        }
      end
    end
  end

  let(:collection) do
    [OpenStruct.new(id: 1, name: "foo"), OpenStruct.new(id: 2, name: "bar")]
  end

  subject { described_class.new(collection, serializer) }

  describe "export" do
    it "exports the collection using the right serializer" do
      json = JSON.parse(subject.export.read)
      expect(json[0]).to eq("id" => 1, "serialized_name" => "foo")
      expect(json[1]).to eq("id" => 2, "serialized_name" => "bar")
    end
  end
end
