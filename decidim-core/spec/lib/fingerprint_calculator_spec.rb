# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FingerprintCalculator do
    it "calculates a unique fingerprint for a given data" do
      calculator1 = described_class.new(foo: "bar")
      calculator2 = described_class.new(foo: "bar")
      calculator3 = described_class.new(bar: "baz")

      expect(calculator1.value).to be_a_kind_of(String)
      expect(calculator2.value).to eq(calculator1.value)
      expect(calculator3.value).not_to eq(calculator1.value)
    end

    it "calculates the same fingerprint regardless of key order" do
      calculator1 = described_class.new(foo: { cory: "wong", bob: "ross" }, bar: "baz")
      calculator2 = described_class.new(bar: "baz", foo: { bob: "ross", cory: "wong" })

      expect(calculator1.value).to eq(calculator2.value)
      expect(calculator1.source).to eq(calculator2.source)
    end
  end
end
