# frozen_string_literal: true

require "spec_helper"

describe "Fingerprint proposal", type: :system do
  let(:manifest_name) { "proposals" }

  let!(:fingerprintable) do
    create(:proposal, component:)
  end

  include_examples "fingerprint"
end
