# frozen_string_literal: true

module Decidim
  # The form object of ephemeral users.
  class EphemeralUserForm < Form
    mimic :user

    attribute :locale
    attribute :name
    attribute :nickname
    attribute :organization
    attribute :verified, Boolean, default: false
    attribute :onboarding_data, Hash, default: {}

    def name
      super || I18n.t("decidim.ephemeral_user", locale:)
    end

    def nickname
      super || User.nicknamize(name, organization.id)
    end
  end
end
