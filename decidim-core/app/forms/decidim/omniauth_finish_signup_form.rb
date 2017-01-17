# frozen_string_literal: true

module Decidim
  # A form object used to fisnish signup from omniauth data
  class OmniauthFinishSignupForm < Form
    mimic :user

    attribute :email, String
    attribute :name, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :provider, String
    attribute :uid, String
    attribute :tos_agreement, Boolean

    def oauth_signature
      return "1234"
      OmniauthFinishSignupForm.create_signature(provider, uid)
    end

    def self.create_signature(provider, uid)
      Digest::MD5.hexdigest("#{provider}-#{uid}-#{Rails.application.secrets.secret_key_base}")
    end

    def self.verify_signature(provider, uid, signature)
      create_signature(provider, uid) === signature
    end
  end
end
