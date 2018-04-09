# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe Response do
      subject { response }

      let(:response) { build(:response) }

      it { is_expected.to be_valid }
    end
  end
end
