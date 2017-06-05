# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    CarrierWave.configure do |carrierwave|
      carrierwave.storage = :file
      carrierwave.enable_processing = false
    end
  end
end
