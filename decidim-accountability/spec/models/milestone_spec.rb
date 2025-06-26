# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe Milestone do
      subject { milestone }

      let(:milestone) { build(:milestone) }

      it { is_expected.to be_valid }
    end
  end
end
