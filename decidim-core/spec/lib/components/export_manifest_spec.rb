# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Components::ExportManifest do
    subject { described_class.new(name, component_manifest) }

    let(:component_manifest) { Decidim::ComponentManifest.new }
    let(:name) { "foo" }

    describe "#name" do
      it "returns the symbolized initialization name" do
        expect(subject.name).to eq(:foo)
      end
    end

    describe "#component_manifest" do
      it "returns the parent component manifest" do
        expect(subject.component_manifest).to eq(component_manifest)
      end
    end

    describe "#collection" do
      it "stores the block when a block is provided and returns it when it isnt" do
        block = -> {}
        subject.collection(&block)
        expect(subject.collection).to eq(block)
      end
    end

    describe "#serializer" do
      context "when no serializer is specified" do
        it "returns the default serializer" do
          expect(subject.serializer).to eq(Decidim::Exporters::Serializer)
        end
      end

      context "when a serializer is set" do
        it "returns the serializer" do
          klass = Class.new
          subject.serializer klass
          expect(subject.serializer).to eq(klass)
        end
      end
    end
  end
end
