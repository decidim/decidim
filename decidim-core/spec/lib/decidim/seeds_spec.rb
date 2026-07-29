# frozen_string_literal: true

require "spec_helper"
require "decidim/seeds"

module Decidim
  describe Seeds do
    describe "::SEEDS_CONFIG" do
      it "defines both the slow and fast keys for all configs" do
        expect(
          described_class::SEEDS_CONFIG.values.all? { |item| item.keys == [:slow, :fast] }
        ).to be(true)
      end
    end
  end
end
