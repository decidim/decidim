# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe Vote do
      subject { vote }

      let(:vote) { build :vote }

      it { is_expected.to be_valid }
    end
  end
end
