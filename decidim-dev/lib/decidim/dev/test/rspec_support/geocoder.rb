RSpec.configure do |config|
  config.before(:each) do
    # Set geocoder configuration in test mode
    Decidim.geocoder = {
      static_map_url: "http://www.example.org",
      here_app_id: '1234',
      here_app_code: '5678'
    }
    Geocoder.configure(lookup: :test)
  end
end