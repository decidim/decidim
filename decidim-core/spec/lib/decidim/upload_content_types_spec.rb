# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UploadContentTypes do
    describe ".normalize" do
      it "keeps the content type as it is" do
        expect(described_class.normalize("image/png")).to eq("image/png")
      end

      it "removes the content type parameters" do
        expect(described_class.normalize("image/png;charset=binary")).to eq("image/png")
      end

      it "normalizes the casing, as content types are case insensitive" do
        expect(described_class.normalize("IMAGE/PNG")).to eq("image/png")
      end

      it "handles blank values" do
        expect(described_class.normalize(nil)).to eq("")
      end
    end

    describe ".format" do
      it "returns the format a content type belongs to" do
        expect(described_class.format("image/png")).to eq(:png)
      end

      it "returns the format for an alias of the format" do
        expect(described_class.format("image/jpg")).to eq(:jpeg)
      end

      it "returns the format when the content type has parameters" do
        expect(described_class.format("image/heif;charset=binary")).to eq(:heif)
      end

      it "returns nil for a content type of an unknown format" do
        expect(described_class.format("text/html")).to be_nil
      end
    end

    describe ".match?" do
      it "accepts the content type of the format" do
        expect(described_class.match?(:jpeg, "image/jpeg")).to be(true)
      end

      it "accepts the aliases accepted for the same format" do
        expect(described_class.match?(:jpeg, "image/jpg")).to be(true)
        expect(described_class.match?(:jpeg, "IMAGE/PJPEG;charset=binary")).to be(true)
      end

      it "rejects the content types of other formats" do
        expect(described_class.match?(:jpeg, "image/png")).to be(false)
      end
    end

    describe ".accepted_types" do
      it "returns the accepted content types for the format of a content type" do
        expect(described_class.accepted_types("image/jpg")).to eq(described_class::FORMAT_CONTENT_TYPES[:jpeg])
      end

      it "returns nil for a content type of an unknown format" do
        expect(described_class.accepted_types("text/html")).to be_nil
      end
    end
  end
end
