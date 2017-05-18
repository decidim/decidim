# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Feature do
    let(:feature) { build(:feature, manifest_name: "dummy") }
    subject { feature }

    it { is_expected.to be_valid }

    include_examples "publicable"
  end
end
