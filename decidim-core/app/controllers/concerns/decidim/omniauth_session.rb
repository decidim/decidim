# frozen_string_literal: true

module Decidim
  module OmniauthSession
    extend ActiveSupport::Concern

    AUTHENTICATION_METHOD_OMNIAUTH = "omniauth"

    def signed_in_via_omniauth?
      session.fetch(:authentication_method, nil) == AUTHENTICATION_METHOD_OMNIAUTH
    end

    def mark_omniauth_sign_in
      session[:authentication_method] = AUTHENTICATION_METHOD_OMNIAUTH
    end
  end
end
