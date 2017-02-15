# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Results
    describe Result do
      let(:result) { build :result }
      subject { result }

      it { is_expected.to be_valid }

      include_examples "has feature"
      include_examples "has scope"
      include_examples "has category"
      include_examples "has reference"
    end
  end
end
