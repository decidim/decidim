# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe Result do
      subject { result }

      let(:result) { build :result }

      it { is_expected.to be_valid }

      it { is_expected.to be_versioned }

      include_examples "has component"
      include_examples "has scope"
      include_examples "has category"
      include_examples "has reference"
      include_examples "resourceable"
    end
  end
end
