# frozen_string_literal: true
require "spec_helper"

describe Decidim do
  describe "seed!" do
    around do |example|
      CarrierWave.configure { |c| c.enable_processing = true }
      example.run
      CarrierWave.configure { |c| c.enable_processing = false }
    end

    it "actually seeds" do
      expect { described_class.seed! }.to_not raise_error
    end
  end
end
