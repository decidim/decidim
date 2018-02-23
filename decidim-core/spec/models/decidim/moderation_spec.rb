# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Moderation do
    subject { moderation }

    let(:moderation) { build(:moderation) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }
  end
end
