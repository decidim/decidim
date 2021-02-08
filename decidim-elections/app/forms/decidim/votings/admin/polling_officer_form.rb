# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class PollingOfficerForm < Decidim::Form
        attribute :name, String
        attribute :email, String

        validates :email, presence: true, format: { with: ::Devise.email_regexp }
        validates :name, presence: true, format: { with: UserBaseEntity::REGEXP_NAME }
      end
    end
  end
end
