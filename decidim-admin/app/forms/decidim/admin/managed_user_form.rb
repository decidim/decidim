# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to create managed users from the admin dashboard.
    #
    class ManagedUserForm < Form
      attribute :name, String

      validates :name, presence: true
      validate :authorization_uniqueness

      def initialize(attributes)
        extend(Virtus.model)

        attribute(:authorization, attributes.dig(:authorization, :handler_name).classify.constantize)

        super
      end

      private

      def authorization_uniqueness
        errors.add :authorization, :invalid if Authorization.where(
          user: current_organization.users,
          name: authorization.handler_name,
          unique_id: authorization.unique_id
        ).exists?
      end
    end
  end
end
