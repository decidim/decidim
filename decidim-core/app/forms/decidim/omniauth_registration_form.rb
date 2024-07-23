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
    attribute :oauth_signature, String
    attribute :avatar_url, String
    attribute :raw_data, Hash

    validates :email, presence: true
    validates :name, presence: true
    validates :provider, presence: true
    validates :uid, presence: true

    validates :email, presence: true, "valid_email_2/email": { disposable: true }
    validate :email_unique_in_organization

    def self.create_signature(provider, uid)
      Digest::MD5.hexdigest("#{provider}-#{uid}-#{Rails.application.secrets.secret_key_base}")
    end

    def normalized_nickname
      UserBaseEntity.nicknamize(nickname || name, organization: current_organization)
    end

    private

    def email_unique_in_organization
      errors.add :email, :taken if valid_users.find_by(email:, organization: current_organization).present?
    end

    def valid_users
      UserBaseEntity.where(invitation_token: nil)
    end
  end
end
