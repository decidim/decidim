RSpec.configure do |config|
  config.before(:each) do
    # Set geocoder configuration in test mode
    Decidim.geocoder = nil
    Geocoder.configure(lookup: :test)
  end
end