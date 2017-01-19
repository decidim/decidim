# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    attribute :name, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :tos_agreement, Boolean

    attribute :user_group_name, String
    attribute :user_group_document_number, String
    attribute :user_group_phone, String

    validates :name, presence: true
    validates :email, presence: true
    validates :password, presence: true, confirmation: true
    validates :tos_agreement, allow_nil: false, acceptance: true
  end
end
