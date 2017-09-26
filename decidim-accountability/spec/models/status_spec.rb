# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe Status do
      let(:status) { build :accountability_status }
      subject { status }

      it { is_expected.to be_valid }

      include_examples "has feature"
    end
  end
end
