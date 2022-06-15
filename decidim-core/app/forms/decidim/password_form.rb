# frozen_string_literal: true

module Decidim
  class PasswordForm < Form
    attribute :password
    attribute :password_confirmation

    validates :password, confirmation: true
  end
end
