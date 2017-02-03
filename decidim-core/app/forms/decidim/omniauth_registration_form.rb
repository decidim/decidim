# frozen_string_literal: true

module Decidim
  # A form object used to fisnish signup from omniauth data
  class OmniauthRegistrationForm < Form
    mimic :user

    attribute :email, String
    attribute :name, String
    attribute :provider, String
    attribute :uid, String
    attribute :tos_agreement, Boolean
    attribute :oauth_signature, String

    validates :email, presence: true
    validates :name, presence: true
    validates :provider, presence: true
    validates :uid, presence: true

    def self.create_signature(provider, uid)
      Digest::MD5.hexdigest("#{provider}-#{uid}-#{Rails.application.secrets.secret_key_base}")
    end
  end
end
