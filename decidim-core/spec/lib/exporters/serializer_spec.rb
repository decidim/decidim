# frozen_string_literal: true
require "spec_helper"

describe Decidim::Exporters::Serializer do
  let(:subject) { described_class.new(resource) }
  let(:resource) { OpenStruct.new(id: 1, name: "John") }

  describe "#serialize" do
    it "turns the object into a hash" do
      expect(subject.serialize).to eq(id: 1, name: "John")
    end
  end
end
