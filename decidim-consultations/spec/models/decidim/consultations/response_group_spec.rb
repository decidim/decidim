# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe ResponseGroup do
      subject { response_group }

      let(:response_group) { build(:response_group) }

      it { is_expected.to be_valid }
    end
  end
end
