# frozen_string_literal: true

require "spec_helper"

describe "Fingerprint proposal" do
  let(:manifest_name) { "proposals" }

  let!(:fingerprintable) do
    create(:proposal, component:)
  end

  include_examples "fingerprint"

  context "when proposal body text has multiple spaces in a row" do
    let!(:fingerprintable) do
      create(:proposal, component:, body: "Spaceous   body text")
    end

    include_examples "consistent fingerprint"
  end
end
