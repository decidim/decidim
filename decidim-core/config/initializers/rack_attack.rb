# frozen_string_literal: true

require "rack/attack"

Rails.application.configure do |config|
  config.middleware.use Rack::Attack
end

Rack::Attack.throttle("requests by ip", limit: 10, period: 1, &:ip)

# Throttle login attempts for a given email parameter to 6 reqs/minute
# Return the email as a discriminator on POST /users/sign_in requests
Rack::Attack.throttle("limit logins per email", limit: 6, period: 60) do |request|
  if request.path == "/users/sign_in" && request.post?
    request.params["user"]["email"]
  end
end


# Throttle login attempts for a given email parameter to 6 reqs/minute
# Return the email as a discriminator on POST /users/sign_in requests
Rack::Attack.throttle("limit password recovery attempts per email", limit: 6, period: 60) do |request|
  if request.path == "/users/password" && request.post?
    request.params["user"]["email"]
  end
end