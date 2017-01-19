# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    attribute :sign_up_as, String
    attribute :name, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :tos_agreement, Boolean

    attribute :user_group_name, String
    attribute :user_group_document_number, String
    attribute :user_group_phone, String

    validates :sign_up_as, inclusion: { in: %w(user user_group) }
    validates :name, presence: true
    validates :email, presence: true
    validates :password, presence: true, confirmation: true
    validates :tos_agreement, allow_nil: false, acceptance: true

    validates :user_group_name, presence: true, if: :is_user_group?
    validates :user_group_document_number, presence: true, if: :is_user_group?
    validates :user_group_phone, presence: true, if: :is_user_group?
    
    def is_user_group?
      sign_up_as == "user_group"
    end
  end
end
