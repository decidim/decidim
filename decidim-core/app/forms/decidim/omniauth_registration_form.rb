# frozen_string_literal: true

module Decidim
  # A form object used to finish signup from omniauth data
  class OmniauthRegistrationForm < Form
    mimic :user

    attribute :email, String
    attribute :name, String
    attribute :nickname, String
    attribute :provider, String
    attribute :uid, String
    attribute :tos_agreement, Boolean
    attribute :newsletter, Boolean
    attribute :oauth_signature, String
    attribute :avatar_url, String
    attribute :raw_data, Hash

    validates :email, presence: true
    validates :name, presence: true
    validates :provider, presence: true
    validates :uid, presence: true

    def self.create_signature(provider, uid)
      Digest::MD5.hexdigest("#{provider}-#{uid}-#{Rails.application.secret_key_base}")
    end

    def normalized_nickname
      UserBaseEntity.nicknamize(nickname || name, current_organization.id)
    end

    def newsletter_at
      return nil unless newsletter?

      Time.current
    end

    def valid_tos?
      return if tos_agreement.nil?

      errors.add :tos_agreement, :accepted
    end
  end
end
