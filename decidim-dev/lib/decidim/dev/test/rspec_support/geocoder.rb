# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    # Set geocoder configuration in test mode
    Decidim.geocoder = {
      static_map_url: "https://www.example.org/my_static_map",
      here_app_id: "1234",
      here_app_code: "5678"
    }
    Geocoder.configure(lookup: :test)
  end

  config.before(:each, :serves_map) do
    stub_request(:get, %r{https://www\.example\.org/my_static_map})
      .to_return(body: "map_data")
  end
end
