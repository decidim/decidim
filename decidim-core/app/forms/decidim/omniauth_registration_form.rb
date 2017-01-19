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
    attribute :oauth_signature, String

    validates :email, presence: true
    validates :name, presence: true
    validates :provider, presence: true
    validates :uid, presence: true
    validates :tos_agreement, acceptance: true, allow_nil: false

    validate :verify_oauth_signature

    def tos_agreement
      %w(facebook twitter google_oauth2).include?(provider.to_s) || super
    end

    def self.create_signature(provider, uid)
      Digest::MD5.hexdigest("#{provider}-#{uid}-#{Rails.application.secrets.secret_key_base}")
    end

    private

    def verify_oauth_signature
      errors.add :oauth_signature, "Invalid oauth signature" if oauth_signature != OmniauthRegistrationForm.create_signature(provider, uid)
    end
  end
end
