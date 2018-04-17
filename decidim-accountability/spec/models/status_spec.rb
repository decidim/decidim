# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe Status do
      subject { status }

      let(:status) { build :status }

      it { is_expected.to be_valid }

      include_examples "has component"
    end
  end
end
