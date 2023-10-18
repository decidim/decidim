# frozen_string_literal: true

module Decidim
  class PasswordForm < Form
    attribute :password

    validates :password, presence: true
  end
end
