# frozen_string_literal: true

module Decidim
  # A form object used to invite admins to an organization.
  #
  class AccountForm < Form
    mimic :user

    attribute :name
    attribute :email
    attribute :password
    attribute :password_confirmation
    attribute :avatar

    validates :name, presence: true
    validates :email, presence: true
  end
end
