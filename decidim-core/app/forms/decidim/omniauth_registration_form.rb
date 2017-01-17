# frozen_string_literal: true

module Decidim
  # A form object used to fisnish signup from omniauth data
  class OmniauthRegistrationForm < Form
    mimic :user

    attribute :email, String
    attribute :email_verified, Boolean
    attribute :name, String
    attribute :provider, String
    attribute :uid, String
    attribute :tos_agreement, Boolean

    validates :email, presence: true
    validates :name, presence: true
    validates :provider, presence: true
    validates :uid, presence: true
    validates :tos_agreement, acceptance: true, allow_nil: false, if: ->(form) { form.provider.to_s != "facebook" }

    def oauth_signature
      OmniauthRegistrationForm.create_signature(provider, uid)
    end

    def self.create_signature(provider, uid)
      Digest::MD5.hexdigest("#{provider}-#{uid}-#{Rails.application.secrets.secret_key_base}")
    end

    def self.verify_signature(provider, uid, signature)
      create_signature(provider, uid) === signature
    end
  end
end
