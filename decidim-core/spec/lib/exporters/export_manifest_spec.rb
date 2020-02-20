# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::ExportManifest do
    subject { described_class.new(name, manifest) }

    let(:manifest) { Decidim::ComponentManifest.new }
    let(:name) { "foo" }

    describe "#name" do
      it "returns the symbolized initialization name" do
        expect(subject.name).to eq(:foo)
      end
    end

    describe "#manifest" do
      it "returns the parent manifest" do
        expect(subject.manifest).to eq(manifest)
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

    describe "#formats" do
      context "when no formats are specified" do
        it "returns the default formats array" do
          expect(subject.formats).to eq(described_class::DEFAULT_FORMATS)
        end
      end

      context "when formats are set" do
        let(:formats) { %w(CSV PDF) }

        before do
          subject.formats formats
        end

        it "returns the formats array" do
          expect(subject.formats).to eq(formats)
        end

        it "loads the exporter classes for each format" do
          expect(Decidim::Exporters.const_get(formats.first)).to be_present
          expect(Decidim::Exporters.const_get(formats.second)).to be_present
        end
      end
    end
  end
end
