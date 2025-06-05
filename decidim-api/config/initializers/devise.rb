# frozen_string_literal: true

Devise.jwt do |jwt|
  # In order to be compatible with the jwt authentication, we need to set these
  # configurations. JWT secret is being used by the devise-jwt to generate the
  # tokens, once the user authenticated. If it is not set correctly, the API
  # authentication does not work.
  #
  # Note that the `dispatch_requests` and `revocation_requests` paths are the
  # full paths because we do not want the JWT tokens to be dispatched or revoked
  # during normal Decidim user sign ins or sign outs. This also requires a small
  # override to `Warden::JWTAuth` which is defined at
  # `decidim-api/lib/warden/jwt_auth/decidim_overrides.rb`.
  jwt.secret = Decidim::Env.new("DECIDIM_API_JWT_SECRET").value
  next unless jwt.secret

  jwt.dispatch_requests = [
    ["POST", %r{^/api/sign_in$}]
  ]
  jwt.revocation_requests = [
    ["DELETE", %r{^/api/sign_out$}]
  ]
  jwt.expiration_time = Decidim::Api.jwt_expires_in.minutes.to_i
  jwt.aud_header = "X_JWT_AUD"
end
