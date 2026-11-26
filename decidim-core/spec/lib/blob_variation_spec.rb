# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe BlobVariation do
    def encode(value)
      Base64.strict_encode64(ActiveSupport::JSON.encode(value))
    end

    describe ".parse" do
      it "accepts the supported transformations" do
        expect(described_class.parse(encode(format: "png", resize_to_limit: [100, 100]))).to eq(
          format: "png",
          resize_to_limit: [100, 100]
        )
      end

      it "normalizes string keys and formats" do
        expect(described_class.parse(encode("format" => "PNG", "resize_to_fit" => [100, 200]))).to eq(
          format: "png",
          resize_to_fit: [100, 200]
        )
      end

      it "accepts a nil dimension for resize_to_fit and resize_to_limit" do
        expect(described_class.parse(encode(resize_to_fit: [nil, 1000]))).to eq(
          resize_to_fit: [nil, 1000]
        )
        expect(described_class.parse(encode(resize_to_limit: [nil, 1000]))).to eq(
          resize_to_limit: [nil, 1000]
        )
      end

      it "accepts two dimensions for resize_to_fill and resize_and_pad" do
        expect(described_class.parse(encode(resize_to_fill: [100, 100]))).to eq(
          resize_to_fill: [100, 100]
        )
        expect(described_class.parse(encode(resize_and_pad: [100, 100]))).to eq(
          resize_and_pad: [100, 100]
        )
      end

      it "rejects unknown transformations" do
        expect(described_class.parse(encode("instance_eval" => "1", "format" => "png"))).to be_nil
      end

      it "rejects loader and saver options" do
        expect(described_class.parse(encode(loader: { page: 0 }, format: "png"))).to be_nil
        expect(described_class.parse(encode(saver: { quality: 90 }, format: "png"))).to be_nil
      end

      it "rejects combine_options" do
        expect(described_class.parse(encode(combine_options: { resize: "100x100" }))).to be_nil
      end

      it "rejects non-hash values" do
        expect(described_class.parse(encode(["resize_to_limit", [100, 100]]))).to be_nil
        expect(described_class.parse(encode("hello"))).to be_nil
      end

      it "rejects empty transformations" do
        expect(described_class.parse(encode({}))).to be_nil
      end

      it "rejects invalid dimensions" do
        expect(described_class.parse(encode(resize_to_limit: [0, 100]))).to be_nil
        expect(described_class.parse(encode(resize_to_limit: [100, 5000]))).to be_nil
        expect(described_class.parse(encode(resize_to_limit: ["100", 100]))).to be_nil
        expect(described_class.parse(encode(resize_to_limit: [nil, nil]))).to be_nil
      end

      it "rejects a variation with a single dimension" do
        expect(described_class.parse(encode(resize_to_fit: [100]))).to be_nil
        expect(described_class.parse(encode(resize_to_limit: [100]))).to be_nil
        expect(described_class.parse(encode(resize_to_fill: [100]))).to be_nil
        expect(described_class.parse(encode(resize_and_pad: [100]))).to be_nil
      end

      it "rejects a variation with more than two dimensions" do
        expect(described_class.parse(encode(resize_to_limit: [100, 100, 100]))).to be_nil
      end

      it "rejects nil dimensions for resize_to_fill and resize_and_pad" do
        expect(described_class.parse(encode(resize_to_fill: [100, nil]))).to be_nil
        expect(described_class.parse(encode(resize_to_fill: [nil, 100]))).to be_nil
        expect(described_class.parse(encode(resize_and_pad: [100, nil]))).to be_nil
        expect(described_class.parse(encode(resize_and_pad: [nil, 100]))).to be_nil
      end

      it "rejects unsupported formats" do
        expect(described_class.parse(encode(format: "html"))).to be_nil
      end

      it "rejects invalid base64" do
        expect(described_class.parse("!!!")).to be_nil
      end

      it "rejects invalid JSON" do
        expect(described_class.parse(Base64.strict_encode64("{"))).to be_nil
      end

      it "rejects keys that are too long" do
        expect(described_class.parse("a" * (described_class::MAX_KEY_LENGTH + 1))).to be_nil
      end

      it "rejects too many transformations" do
        value = { format: "png" }
        10.times { |index| value[:"resize_to_fit#{index}"] = [100, 100] }

        expect(described_class.parse(encode(value))).to be_nil
      end
    end

    describe ".normalize_hash" do
      it "accepts symbol keys" do
        expect(described_class.normalize_hash(format: "png", resize_to_limit: [100, 100])).to eq(
          format: "png",
          resize_to_limit: [100, 100]
        )
      end

      it "rejects unsafe keys" do
        expect(described_class.normalize_hash(instance_eval: "1")).to be_nil
      end
    end
  end
end
