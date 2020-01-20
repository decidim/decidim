# frozen_string_literal: true

require "spec_helper"

shared_examples_for "fingerprintable interface" do
  describe "fingerprint" do
    let(:query) { "{ fingerprint { value source } }" }

    it "returns the fingerprint value" do
      expect(response["fingerprint"]["value"]).to eq(model.fingerprint.value)
    end

    it "returns the fingerprint source" do
      expect(response["fingerprint"]["source"]).to eq(model.fingerprint.source)
    end
  end
end
