# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Importers::ImportManifest do
    subject { described_class.new(name, manifest) }

    let(:manifest) { Decidim::ComponentManifest.new }
    let(:name) { "bar" }

    describe "#name" do
      it "returns the symbolized initialization name" do
        expect(subject.name).to eq(:bar)
      end
    end

    describe "#manifest" do
      it "returns the parent manifest" do
        expect(subject.manifest).to eq(manifest)
      end
    end

    context "when a creator is set" do
      it "returns the creator" do
        klass = Class.new
        subject.creator klass
        expect(subject.creator).to eq(klass)
      end
    end

    describe "#formats" do
      it "returns the default formats array" do
        expect(subject.formats).to eq(described_class::DEFAULT_FORMATS)
      end
    end
  end
end
