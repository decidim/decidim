# frozen_string_literal: true

module Decidim
  class AdminPasswordForm < Form
    attribute :password
    attribute :password_confirmation

    validate :passwords_match

    private

    def passwords_match
      password == password_confirmation
    end
  end
end
