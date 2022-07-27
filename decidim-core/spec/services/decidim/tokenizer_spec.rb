# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tokenizer do
  subject { described_class.new(salt: secret, length:) }

  let(:secret) { "secret" }
  let(:length) { 10 }
  let(:string) { "Poems everybody!" }

  describe "digest" do
    it "returns the salt initilzed" do
      expect(subject.salt).to eq(secret)
    end

    it "generates an integer key" do
      expect(subject.int_digest(string)).to be_a(Integer)
      expect(subject.int_digest(string).size).to eq(10)
    end

    it "encodes integers and strings equally" do
      expect(subject.int_digest(10)).to eq(subject.int_digest("10"))
      expect(subject.hex_digest(0.10)).to eq(subject.hex_digest("0.1"))
    end

    it "generates an hexadecimal key" do
      expect(subject.hex_digest(string)).to be_a(String)
      expect(subject.hex_digest(string).size <= 20).to be(true)
    end

    it "generates random secrets" do
      expect(described_class.random_salt).not_to eq(described_class.random_salt)
      expect(described_class.random_salt.size).to eq(64)
    end

    context "when the size is different" do
      let(:length) { 15 }

      it "generates a digest of the propser size" do
        expect(subject.int_digest(string).size).to eq(15)
      end
    end

    context "when no salt is specified" do
      subject { described_class.new }

      it "generates a random string as salt" do
        expect(subject.salt).to be_a(String)
        expect(subject.salt.size).to eq(64)
      end
    end
  end
end
